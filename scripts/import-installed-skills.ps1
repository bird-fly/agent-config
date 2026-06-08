param(
  [string]$RepoRoot = $null,
  [string[]]$SourcePaths = $null,
  [string]$SharedSkillsDir = $null,
  [string]$ClientsDir = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  return [System.IO.Path]::GetFullPath($Path)
}

function Test-AgentConfigRoot {
  param([Parameter(Mandatory = $true)][string]$Path)

  return (
    (Test-Path -LiteralPath (Join-Path $Path "clients")) -and
    (Test-Path -LiteralPath (Join-Path $Path "shared")) -and
    (Test-Path -LiteralPath (Join-Path $Path "scripts"))
  )
}

function Resolve-RepoRoot {
  param([string]$RequestedRoot)

  $scriptRepoRoot = Get-FullPath (Join-Path $PSScriptRoot "..")

  if ($RequestedRoot) {
    $requestedFull = Get-FullPath $RequestedRoot
    if (Test-AgentConfigRoot $requestedFull) {
      return $requestedFull
    }

    Write-Host "RepoRoot '$requestedFull' is not an agent-config root; using script repo root: $scriptRepoRoot"
    return $scriptRepoRoot
  }

  return $scriptRepoRoot
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

function Read-JsonFile {
  param([Parameter(Mandatory = $true)][string]$Path)
  return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json)
}

function Get-DefaultSkillSources {
  $homeDir = [Environment]::GetFolderPath("UserProfile")
  return @(
    (Join-Path $homeDir ".agents/skills"),
    (Join-Path $homeDir ".codex/skills"),
    (Join-Path $homeDir ".claude/skills"),
    (Join-Path $homeDir ".openCode/skills")
  )
}

function Get-SkillDirectories {
  param([Parameter(Mandatory = $true)][string[]]$Paths)

  foreach ($sourcePath in $Paths) {
    if (-not (Test-Path -LiteralPath $sourcePath)) {
      Write-Host "Skipping missing source: $sourcePath"
      continue
    }

    Get-ChildItem -LiteralPath $sourcePath -Directory | Sort-Object Name | ForEach-Object {
      $skillFile = Join-Path $_.FullName "SKILL.md"
      if (Test-Path -LiteralPath $skillFile) {
        [pscustomobject]@{
          name = $_.Name
          path = $_.FullName
        }
      } else {
        Write-Host "Skipping non-skill directory: $($_.FullName)"
      }
    }
  }
}

function Add-SkillToManifest {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath,
    [Parameter(Mandatory = $true)]
    [string[]]$SkillNames
  )

  $manifest = Read-JsonFile $ManifestPath
  $existing = @()
  if ($manifest.PSObject.Properties["skills"]) {
    $existing = @($manifest.skills)
  }

  $merged = [System.Collections.Generic.List[string]]::new()
  foreach ($skillName in $existing) {
    if (-not [string]::IsNullOrWhiteSpace($skillName) -and -not $merged.Contains($skillName)) {
      $merged.Add($skillName)
    }
  }

  foreach ($skillName in $SkillNames) {
    if (-not [string]::IsNullOrWhiteSpace($skillName) -and -not $merged.Contains($skillName)) {
      $merged.Add($skillName)
    }
  }

  $updated = [ordered]@{
    skills = @($merged)
  }

  Write-Utf8NoBom -Path $ManifestPath -Content ($updated | ConvertTo-Json -Depth 8)
}

$repoRootFull = Resolve-RepoRoot -RequestedRoot $RepoRoot
if (-not $SharedSkillsDir) {
  $SharedSkillsDir = Join-Path $repoRootFull "shared/skills"
}
if (-not $ClientsDir) {
  $ClientsDir = Join-Path $repoRootFull "clients"
}
if (-not $SourcePaths) {
  $SourcePaths = Get-DefaultSkillSources
}

$sharedSkillsFull = Get-FullPath $SharedSkillsDir
$clientsFull = Get-FullPath $ClientsDir
$sourcePathFullList = @($SourcePaths | ForEach-Object { Get-FullPath $_ })

New-Item -ItemType Directory -Force -Path $sharedSkillsFull | Out-Null

$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$manifestSkillNames = [System.Collections.Generic.List[string]]::new()
$importedCount = 0
$skippedDuplicateCount = 0

foreach ($skill in (Get-SkillDirectories -Paths $sourcePathFullList)) {
  if (-not $seen.Add($skill.name)) {
    $skippedDuplicateCount += 1
    Write-Host "Skipping duplicate source skill '$($skill.name)': $($skill.path)"
    continue
  }

  $destination = Join-Path $sharedSkillsFull $skill.name
  if (Test-Path -LiteralPath $destination) {
    $skippedDuplicateCount += 1
    Write-Host "Keeping existing shared skill '$($skill.name)': $destination"
  } else {
    Copy-Item -LiteralPath $skill.path -Destination $destination -Recurse -Force
    $importedCount += 1
    Write-Host "Imported skill '$($skill.name)' from $($skill.path)"
  }

  if (-not $manifestSkillNames.Contains($skill.name)) {
    $manifestSkillNames.Add($skill.name)
  }
}

if ($manifestSkillNames.Count -eq 0) {
  Write-Host "No installed skills found to import."
  return
}

$manifestPaths = Get-ChildItem -LiteralPath $clientsFull -Directory |
  Sort-Object Name |
  ForEach-Object { Join-Path $_.FullName "skills.manifest.json" } |
  Where-Object { Test-Path -LiteralPath $_ }

foreach ($manifestPath in $manifestPaths) {
  Add-SkillToManifest -ManifestPath $manifestPath -SkillNames @($manifestSkillNames)
  Write-Host "Updated manifest: $manifestPath"
}

Write-Host "Skill import complete. Imported: $importedCount; duplicates kept/skipped: $skippedDuplicateCount; manifest skills considered: $($manifestSkillNames.Count)."
