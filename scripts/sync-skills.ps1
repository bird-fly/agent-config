param(
  [Parameter(Mandatory = $true)]
  [string]$RepoRoot,
  [string]$ConfigPath = $null,
  [ValidateSet("Auto", "Link", "Copy")]
  [string]$Mode = "Auto",
  [string]$SkillCenterPath = "$env:USERPROFILE\.localAi\skills"  # 新增：技能中心路径
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)
  return [System.IO.Path]::GetFullPath($expandedPath)
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

function Unquote-MetadataValue {
  param([Parameter(Mandatory = $true)][string]$Value)

  $trimmed = $Value.Trim()
  if ($trimmed.Length -ge 2) {
    $first = $trimmed.Substring(0, 1)
    $last = $trimmed.Substring($trimmed.Length - 1, 1)
    if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
      return $trimmed.Substring(1, $trimmed.Length - 2)
    }
  }

  return $trimmed
}

function Get-SkillNameFromFile {
  param([Parameter(Mandatory = $true)][string]$Path)

  $lines = Get-Content -LiteralPath $Path
  $inFrontmatter = $false
  $frontmatterStarted = $false

  foreach ($line in $lines) {
    if ($line.Trim() -eq "---") {
      if (-not $frontmatterStarted) {
        $frontmatterStarted = $true
        $inFrontmatter = $true
        continue
      }

      if ($inFrontmatter) {
        break
      }
    }

    if ($frontmatterStarted -and -not $inFrontmatter) {
      break
    }

    if ($frontmatterStarted -and $inFrontmatter -and $line -match "^\s*name\s*:\s*(.+?)\s*$") {
      return (Unquote-MetadataValue -Value $matches[1])
    }
  }

  return $null
}

function Assert-SkillNameMatches {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillName,
    [Parameter(Mandatory = $true)]
    [string]$SkillFile
  )

  $declaredName = Get-SkillNameFromFile -Path $SkillFile
  if (-not $declaredName) {
    throw "Missing skill metadata name in: $SkillFile"
  }

  if ($declaredName -ne $SkillName) {
    throw "Skill directory '$SkillName' must match SKILL.md name '$declaredName': $SkillFile"
  }
}

function Assert-ManagedSkillDestination {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$SkillName
  )

  if (-not (Test-Path -LiteralPath $Destination)) {
    return
  }

  $destinationSkillFile = Join-Path $Destination "SKILL.md"
  if (-not (Test-Path -LiteralPath $destinationSkillFile)) {
    throw "Refusing to replace unmanaged destination: $Destination"
  }

  $declaredName = Get-SkillNameFromFile -Path $destinationSkillFile
  if ($declaredName -ne $SkillName) {
    throw "Refusing to replace unmanaged destination: $Destination"
  }
}

function Test-IsPluginSkill {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillPath
  )
  
  if (-not (Test-Path -LiteralPath $SkillPath)) {
    return $false
  }
  
  $item = Get-Item -LiteralPath $SkillPath
  if ($item.LinkType -ne "Junction" -and $item.LinkType -ne "SymbolicLink") {
    return $false
  }
  
  # 检查是否指向 .localAi\plugins（插件中心）
  $target = $item.Target
  if (-not $target) {
    return $false
  }
  
  return $target -like "*\.localAi\plugins\*"
}

function Sync-SkillViaCenter {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$SkillName,
    [Parameter(Mandatory = $true)]
    [string]$CenterPath,
    [Parameter(Mandatory = $true)]
    [string]$Mode
  )
  
  # Link 模式：先复制到技能中心，再链接到平台
  if ($Mode -eq "Link") {
    $centerSkillPath = Join-Path $CenterPath $SkillName
    
    # 确保技能中心目录存在
    if (-not (Test-Path $CenterPath)) {
      New-Item -ItemType Directory -Force -Path $CenterPath | Out-Null
    }
    
    # 复制到技能中心（如果不存在或需要更新）
    if (-not (Test-Path $centerSkillPath)) {
      Copy-Item -Recurse -Force $Source $centerSkillPath
    }
    
    # 从技能中心创建符号链接到平台
    if (Test-Path $Destination) {
      Remove-Item -Recurse -Force $Destination
    }
    
    try {
      cmd /c mklink /J "$Destination" "$centerSkillPath" | Out-Null
      return "Link (via center)"
    } catch {
      # 如果无法创建链接，直接复制
      Copy-Item -Recurse -Force $Source $Destination
      return "Copy (fallback)"
    }
  }
  
  # Copy 模式：直接从源复制到目标
  if (Test-Path $Destination) {
    Remove-Item -Recurse -Force $Destination
  }
  Copy-Item -Recurse -Force $Source $Destination
  return "Copy"
}

function Assert-SafeSkillsTarget {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = Get-FullPath $Path
  $root = [System.IO.Path]::GetPathRoot($fullPath)
  $leaf = Split-Path -Leaf $fullPath

  if ([string]::IsNullOrWhiteSpace($leaf)) {
    throw "Skills target must not be a drive root: $fullPath"
  }

  if ($fullPath -eq $root) {
    throw "Skills target must not be a drive root: $fullPath"
  }
}

function Remove-ManifestExcludedSkills {
  param(
    [Parameter(Mandatory = $true)]
    [string]$SkillsTarget,
    [Parameter(Mandatory = $true)]
    [string[]]$ManifestSkillNames,
    [Parameter(Mandatory = $true)]
    [string]$ClientName
  )

  if (-not (Test-Path -LiteralPath $SkillsTarget)) {
    return
  }

  Assert-SafeSkillsTarget -Path $SkillsTarget

  $manifestSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  foreach ($skillName in $ManifestSkillNames) {
    if (-not [string]::IsNullOrWhiteSpace($skillName)) {
      [void]$manifestSet.Add($skillName)
    }
  }

  $localSkillDirs = Get-ChildItem -LiteralPath $SkillsTarget -Directory | Sort-Object Name
  foreach ($localSkillDir in $localSkillDirs) {
    if ($manifestSet.Contains($localSkillDir.Name)) {
      continue
    }

    # 检查是否为插件技能（不删除插件技能）
    if (Test-IsPluginSkill -SkillPath $localSkillDir.FullName) {
      Write-Host "⏭️  保留 $clientName 插件技能 '$($localSkillDir.Name)'（不在 manifest 中，但来自插件中心）" -ForegroundColor Cyan
      continue
    }

    $localSkillFile = Join-Path $localSkillDir.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $localSkillFile)) {
      Write-Host "Skipping $clientName manifest-excluded non-skill directory '$($localSkillDir.Name)'."
      continue
    }

    $declaredName = Get-SkillNameFromFile -Path $localSkillFile
    if ($declaredName -ne $localSkillDir.Name) {
      Write-Host "Skipping $clientName manifest-excluded directory with mismatched skill metadata '$($localSkillDir.Name)'."
      continue
    }

    Remove-Item -LiteralPath $localSkillDir.FullName -Recurse -Force
    Write-Host "Removed $clientName manifest-excluded local skill '$($localSkillDir.Name)'."
  }
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
  $manifestSkillNames = @($manifest.skills)

  # 获取 skillSyncModes 配置
  $skillSyncModes = Get-ObjectProperty -Object $config -Name "skillSyncModes"

  Remove-ManifestExcludedSkills -SkillsTarget $skillsTarget -ManifestSkillNames $manifestSkillNames -ClientName $clientName

  foreach ($skillName in $manifestSkillNames) {
    if ([string]::IsNullOrWhiteSpace($skillName)) {
      throw "Empty skill name in manifest: $manifestPath"
    }

    $source = Join-Path $sharedSkillsDir $skillName
    $skillFile = Join-Path $source "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile)) {
      throw "Missing shared skill file: $skillFile"
    }
    Assert-SkillNameMatches -SkillName $skillName -SkillFile $skillFile

    $destination = Join-Path $skillsTarget $skillName
    
    # 检查是否已存在插件技能（优先级：插件技能 > shared/skills 技能）
    if (Test-Path -LiteralPath $destination) {
      if (Test-IsPluginSkill -SkillPath $destination) {
        Write-Host "⏭️  跳过 $clientName 技能 '$skillName'（插件技能优先）" -ForegroundColor Yellow
        continue
      }
    }
    
    Assert-ManagedSkillDestination -Destination $destination -SkillName $skillName
    
    # 检查是否为特定技能指定了同步模式
    $skillMode = $Mode
    if ($skillSyncModes) {
      $specificMode = Get-ObjectProperty -Object $skillSyncModes -Name $skillName
      if ($specificMode -and ($specificMode -eq "Link" -or $specificMode -eq "Copy")) {
        $skillMode = $specificMode
      }
    }
    
    # 使用新的同步逻辑
    $skillCenterFull = [System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($SkillCenterPath))
    $modeUsed = Sync-SkillViaCenter -Source $source `
                                     -Destination $destination `
                                     -SkillName $skillName `
                                     -CenterPath $skillCenterFull `
                                     -Mode $skillMode

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
