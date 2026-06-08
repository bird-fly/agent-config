param(
  [Parameter(Mandatory = $true)]
  [string]$RepoRoot,
  [string]$ConfigPath = $null,
  [ValidateSet("Auto", "Link", "Copy")]
  [string]$Mode = "Auto"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Resolve-ConfigPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Root,
    [string]$RequestedPath
  )

  if ($RequestedPath) {
    return (Get-FullPath $RequestedPath)
  }

  $localConfig = Join-Path $Root "setup.json"
  if (Test-Path -LiteralPath $localConfig) {
    return (Get-FullPath $localConfig)
  }

  return (Get-FullPath (Join-Path $Root "setup.example.json"))
}

function Read-JsonFile {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json)
}

function Get-ClientConfig {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Config,
    [Parameter(Mandatory = $true)]
    [string]$ClientName
  )

  $property = $Config.clients.PSObject.Properties[$ClientName]
  if ($property) {
    return $property.Value
  }

  return $null
}

function Get-ObjectProperty {
  param(
    [object]$Object,
    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  if (-not $Object) {
    return $null
  }

  $property = $Object.PSObject.Properties[$Name]
  if ($property) {
    return $property.Value
  }

  return $null
}

function Write-Utf8NoBom {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Content
  )

  $parent = Split-Path -Parent $Path
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

$repoRootFull = Get-FullPath $RepoRoot
$configPathFull = Resolve-ConfigPath -Root $repoRootFull -RequestedPath $ConfigPath
if (-not (Test-Path -LiteralPath $configPathFull)) {
  throw "Missing setup config: $configPathFull"
}

$config = Read-JsonFile $configPathFull
$sharedSkillsDir = Join-Path $repoRootFull "shared/skills"
$clientsDir = Join-Path $repoRootFull "clients"
$linkOrCopyScript = Join-Path $repoRootFull "scripts/link-or-copy.ps1"
$statePath = Join-Path $repoRootFull "state/install-map.json"

if (-not (Test-Path -LiteralPath $linkOrCopyScript)) {
  throw "Missing link-or-copy script: $linkOrCopyScript"
}

$stateClients = [ordered]@{}
$clientDirs = Get-ChildItem -LiteralPath $clientsDir -Directory | Sort-Object Name

foreach ($clientDir in $clientDirs) {
  $clientName = $clientDir.Name
  $manifestPath = Join-Path $clientDir.FullName "skills.manifest.json"
  if (-not (Test-Path -LiteralPath $manifestPath)) {
    continue
  }

  $clientConfig = Get-ClientConfig -Config $config -ClientName $clientName
  $skillsTargetValue = Get-ObjectProperty -Object $clientConfig -Name "skillsTarget"
  if (-not $clientConfig -or -not $skillsTargetValue) {
    Write-Host "Skipping $clientName skills; no skillsTarget in config."
    continue
  }

  $skillsTarget = Get-FullPath $skillsTargetValue
  $manifest = Read-JsonFile $manifestPath
  $skillState = [ordered]@{}

  foreach ($skillName in $manifest.skills) {
    if ([string]::IsNullOrWhiteSpace($skillName)) {
      throw "Empty skill name in manifest: $manifestPath"
    }

    $source = Join-Path $sharedSkillsDir $skillName
    $skillFile = Join-Path $source "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile)) {
      throw "Missing shared skill file: $skillFile"
    }

    $destination = Join-Path $skillsTarget $skillName
    $result = & $linkOrCopyScript -Source $source -Destination $destination -Mode $Mode
    $modeUsed = ($result | Select-Object -Last 1).mode
    if (-not $modeUsed) {
      $modeUsed = $Mode
    }

    $skillState[$skillName] = [ordered]@{
      source = (Get-FullPath $source)
      destination = (Get-FullPath $destination)
      mode = $modeUsed
    }

    Write-Host "Synced $clientName skill '$skillName' via $modeUsed."
  }

  $stateClients[$clientName] = [ordered]@{
    skillsTarget = $skillsTarget
    skills = $skillState
  }
}

$state = [ordered]@{
  version = 1
  updatedAt = [DateTime]::UtcNow.ToString("o")
  clients = $stateClients
}

Write-Utf8NoBom -Path $statePath -Content ($state | ConvertTo-Json -Depth 12)
