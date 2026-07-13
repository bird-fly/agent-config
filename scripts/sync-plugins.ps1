param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = $PWD,
  
  [Parameter(Mandatory = $false)]
  [string]$PluginCenterPath = "$env:USERPROFILE\.localAi\plugins",
  
  [Parameter(Mandatory = $false)]
  [string]$ConfigPath = $null
  # 移除 Mode 参数，插件始终复制到 .localAi/plugins
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-ColorMessage {
  param(
    [string]$Message,
    [string]$Color = "White"
  )
  Write-Host $Message -ForegroundColor $Color
}

function Read-PluginConfig {
  param([string]$ConfigPath)
  
  if (-not $ConfigPath -or -not (Test-Path $ConfigPath)) {
    return $null
  }
  
  try {
    $config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
    return $config.plugins
  } catch {
    Write-ColorMessage "⚠️  无法读取插件配置: $ConfigPath" "Yellow"
    return $null
  }
}

function Test-PluginEnabled {
  param(
    [string]$PluginName,
    [object]$PluginConfig
  )
  
  if (-not $PluginConfig) {
    return $true  # 没有配置，默认启用
  }
  
  # 检查是否有该插件的配置
  $pluginSetting = $PluginConfig.PSObject.Properties[$PluginName]
  if (-not $pluginSetting) {
    return $true  # 未配置，默认启用
  }
  
  # 返回配置值
  return $pluginSetting.Value -eq $true
}

function Sync-PluginToCenter {
  param(
    [string]$PluginName,
    [string]$SourcePath,
    [string]$CenterPath,
    [string]$SyncMode
  )
  
  $targetPath = Join-Path $CenterPath $PluginName
  
  # 检查源是否存在
  if (-not (Test-Path $SourcePath)) {
    Write-ColorMessage "  ⚠️  源路径不存在，跳过: $PluginName" "Yellow"
    return $false
  }
  
  # 如果目标已存在，检查是否需要更新
  if (Test-Path $targetPath) {
    $item = Get-Item $targetPath
    if ($item.LinkType -eq "Junction") {
      Write-ColorMessage "  ✓ $PluginName 已存在 (符号链接)" "Gray"
      return $true
    }
    Write-ColorMessage "  🔄 覆盖已存在的 $PluginName" "Yellow"
    Remove-Item -Recurse -Force $targetPath
  }
  
  # 同步到中心
  if ($SyncMode -eq "Link") {
    try {
      cmd /c mklink /J "$targetPath" "$SourcePath" | Out-Null
      Write-ColorMessage "  ✅ $PluginName (符号链接)" "Green"
      return $true
    } catch {
      Write-ColorMessage "  ⚠️  无法创建符号链接，尝试复制..." "Yellow"
      $SyncMode = "Copy"
    }
  }
  
  if ($SyncMode -eq "Copy") {
    Copy-Item -Recurse -Force $SourcePath $targetPath
    Write-ColorMessage "  ✅ $PluginName (复制)" "Green"
    return $true
  }
  
  return $false
}

function Link-PluginSkillsToPlatform {
  param(
    [string]$PlatformName,
    [string]$PlatformPath,
    [string]$PluginName,
    [string]$CenterPath
  )
  
  if (-not (Test-Path $PlatformPath)) {
    return $null
  }
  
  $pluginPath = Join-Path $CenterPath $PluginName
  $pluginSkillsPath = Join-Path $pluginPath "skills"
  $platformSkillsPath = Join-Path $PlatformPath "skills"
  
  # 特殊处理 jd-multica-skills：skills 直接在根目录下
  if ($PluginName -eq "jd-multica-skills") {
    $pluginSkillsPath = $pluginPath
  }
  
  if (-not (Test-Path $pluginSkillsPath)) {
    return $null
  }
  
  # 确保平台 skills 目录存在
  if (-not (Test-Path $platformSkillsPath)) {
    New-Item -ItemType Directory -Force -Path $platformSkillsPath | Out-Null
  }
  
  # 获取插件中的所有技能
  $skillDirs = Get-ChildItem -Path $pluginSkillsPath -Directory
  
  # 特殊处理 jd-multica-skills：过滤掉非 skill 目录
  if ($PluginName -eq "jd-multica-skills") {
    $skillDirs = $skillDirs | Where-Object { $_.Name -like "multica-*" }
  }
  
  $linkedSkills = @()
  
  foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $sourcePath = $skillDir.FullName
    $targetPath = Join-Path $platformSkillsPath $skillName
    
    # 如果已存在，检查是否已经是正确的链接
    if (Test-Path $targetPath) {
      $item = Get-Item $targetPath
      if ($item.LinkType -eq "Junction" -and $item.Target -eq $sourcePath) {
        continue
      }
      Remove-Item -Recurse -Force $targetPath
    }
    
    # 创建符号链接
    try {
      cmd /c mklink /J "$targetPath" "$sourcePath" | Out-Null
      $linkedSkills += $skillName
    } catch {
      Write-ColorMessage "      ✗ $skillName (失败)" "Red"
    }
  }
  
  return $linkedSkills
}

# 主逻辑
Write-ColorMessage "`n🔌 插件统一管理系统" "Cyan"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$repoRootFull = [System.IO.Path]::GetFullPath($RepoRoot)
$pluginsSourceDir = Join-Path $repoRootFull "shared\plugins"
$pluginCenterFull = [System.IO.Path]::GetFullPath($PluginCenterPath)

# 读取插件配置
if (-not $ConfigPath) {
  $localConfig = Join-Path $repoRootFull "setup.json"
  if (Test-Path $localConfig) {
    $ConfigPath = $localConfig
  } else {
    $ConfigPath = Join-Path $repoRootFull "setup.example.json"
  }
}

$pluginConfig = Read-PluginConfig -ConfigPath $ConfigPath
if ($pluginConfig) {
  Write-ColorMessage "📝 使用插件配置: $ConfigPath" "Gray"
}

# 创建插件中心目录
if (-not (Test-Path $pluginCenterFull)) {
  Write-ColorMessage "📁 创建插件中心: $pluginCenterFull" "Cyan"
  New-Item -ItemType Directory -Force -Path $pluginCenterFull | Out-Null
}

Write-ColorMessage "📂 插件源: $pluginsSourceDir" "Gray"
Write-ColorMessage "📦 插件中心: $pluginCenterFull" "Gray"
Write-ColorMessage "🔗 同步模式: 复制（插件始终复制到中心）`n" "Gray"

# 步骤 1: 同步插件到中心
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 1: 同步插件到中心" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

if (-not (Test-Path $pluginsSourceDir)) {
  Write-ColorMessage "❌ 错误：插件源目录不存在" "Red"
  exit 1
}

$syncedPlugins = @()
$skippedPlugins = @()
$pluginDirs = Get-ChildItem -Path $pluginsSourceDir -Directory

foreach ($pluginDir in $pluginDirs) {
  $pluginName = $pluginDir.Name
  
  # 检查插件是否启用
  if (-not (Test-PluginEnabled -PluginName $pluginName -PluginConfig $pluginConfig)) {
    Write-ColorMessage "  ⏭️  跳过: $pluginName（已禁用）" "Yellow"
    $skippedPlugins += $pluginName
    continue
  }
  
  # 对于 understand-anything，使用内部的 understand-anything-plugin 目录
  $sourcePath = $pluginDir.FullName
  if ($pluginName -eq "understand-anything") {
    $innerPlugin = Join-Path $sourcePath "understand-anything-plugin"
    if (Test-Path $innerPlugin) {
      $sourcePath = $innerPlugin
    }
  }
  
  $synced = Sync-PluginToCenter -PluginName $pluginName `
                                 -SourcePath $sourcePath `
                                 -CenterPath $pluginCenterFull `
                                 -SyncMode "Copy"  # 插件始终使用 Copy 模式
  
  if ($synced) {
    $syncedPlugins += $pluginName
  }
}

if ($syncedPlugins.Count -eq 0) {
  Write-ColorMessage "`n⚠️  没有插件被同步" "Yellow"
}

# 步骤 1.5: 清理已禁用的插件
Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 1.5: 清理已禁用的插件" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$cleanedPlugins = @()
if (Test-Path $pluginCenterFull) {
  $centerPlugins = Get-ChildItem -Path $pluginCenterFull -Directory
  foreach ($centerPlugin in $centerPlugins) {
    $pluginName = $centerPlugin.Name
    
    # 检查插件是否在同步列表中
    if ($syncedPlugins -notcontains $pluginName) {
      # 检查是否被跳过（禁用）
      if ($skippedPlugins -contains $pluginName) {
        Write-ColorMessage "  🗑️  清理已禁用插件: $pluginName" "Yellow"
      } else {
        Write-ColorMessage "  🗑️  清理未知插件: $pluginName" "Gray"
      }
      
      try {
        Remove-Item -Recurse -Force $centerPlugin.FullName
        $cleanedPlugins += $pluginName
      } catch {
        Write-ColorMessage "    ✗ 清理失败: $_" "Red"
      }
    }
  }
}

if ($cleanedPlugins.Count -eq 0) {
  Write-ColorMessage "  ✓ 无需清理" "Gray"
}

# 步骤 2: 链接插件的技能到各平台
Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 2: 链接插件技能到各平台" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$platforms = @(
  @{Name="Claude"; Path="$env:USERPROFILE\.claude"},
  @{Name="Codex"; Path="$env:USERPROFILE\.codex"},
  @{Name="OpenCode"; Path="$env:USERPROFILE\.openCode"}
)

$platformStats = @{}

foreach ($pluginName in $syncedPlugins) {
  Write-ColorMessage "  ${pluginName}:" "Cyan"
  
  foreach ($platform in $platforms) {
    $linkedSkills = Link-PluginSkillsToPlatform -PlatformName $platform.Name `
                                                 -PlatformPath $platform.Path `
                                                 -PluginName $pluginName `
                                                 -CenterPath $pluginCenterFull
    
    if ($linkedSkills -and $linkedSkills.Count -gt 0) {
      Write-ColorMessage "    ✓ $($platform.Name): $($linkedSkills.Count) 个技能" "Gray"
      if (-not $platformStats.ContainsKey($platform.Name)) {
        $platformStats[$platform.Name] = @{}
      }
      $platformStats[$platform.Name][$pluginName] = $linkedSkills.Count
    }
  }
}

# 步骤 2.5: 清理已禁用插件的技能链接
Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 2.5: 清理已禁用插件的技能链接" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

foreach ($pluginName in $cleanedPlugins) {
  Write-ColorMessage "  ${pluginName}:" "Cyan"
  
  foreach ($platform in $platforms) {
    if (-not (Test-Path $platform.Path)) {
      continue
    }
    
    $platformSkillsPath = Join-Path $platform.Path "skills"
    if (-not (Test-Path $platformSkillsPath)) {
      continue
    }
    
    # 查找该插件的技能（通过检查链接目标）
    $removedCount = 0
    $skillDirs = Get-ChildItem -Path $platformSkillsPath -Directory -ErrorAction SilentlyContinue
    
    foreach ($skillDir in $skillDirs) {
      $item = Get-Item $skillDir.FullName -ErrorAction SilentlyContinue
      if ($item -and $item.LinkType -eq "Junction" -and $item.Target -like "*\$pluginName\skills\*") {
        try {
          Remove-Item -Recurse -Force $item.FullName
          $removedCount++
        } catch {
          Write-ColorMessage "      ✗ 删除失败: $($skillDir.Name)" "Red"
        }
      }
    }
    
    if ($removedCount -gt 0) {
      Write-ColorMessage "    ✓ $($platform.Name): 清理 $removedCount 个技能链接" "Gray"
    }
  }
}

if ($cleanedPlugins.Count -eq 0) {
  Write-ColorMessage "  ✓ 无需清理" "Gray"
}

# 步骤 3: 验证
Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 3: 验证安装" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

Write-ColorMessage "插件中心内容:" "Cyan"
Get-ChildItem $pluginCenterFull -Directory | ForEach-Object {
  $item = Get-Item $_.FullName
  $type = if ($item.LinkType) { "→ $($item.Target)" } else { "(真实目录)" }
  Write-ColorMessage "  ✓ $($_.Name) $type" "Gray"
}

Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "✅ 完成！" "Green"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

Write-ColorMessage "📊 统计:" "Cyan"
Write-ColorMessage "  • 同步插件数: $($syncedPlugins.Count)" "White"
if ($skippedPlugins.Count -gt 0) {
  Write-ColorMessage "  • 跳过插件数: $($skippedPlugins.Count) ($($skippedPlugins -join ', '))" "Yellow"
}
if ($cleanedPlugins.Count -gt 0) {
  Write-ColorMessage "  • 清理插件数: $($cleanedPlugins.Count) ($($cleanedPlugins -join ', '))" "Yellow"
}
Write-ColorMessage "  • 插件中心: $pluginCenterFull" "White"

foreach ($platform in $platforms) {
  if ($platformStats.ContainsKey($platform.Name)) {
    $totalSkills = ($platformStats[$platform.Name].Values | Measure-Object -Sum).Sum
    Write-ColorMessage "  • $($platform.Name): $totalSkills 个技能" "White"
  }
}

Write-ColorMessage "`n📝 说明:" "Yellow"
Write-ColorMessage "  • 插件完整存储在: $pluginCenterFull" "White"
Write-ColorMessage "  • 插件的技能链接到: <平台>/skills/<技能名>" "White"
Write-ColorMessage "  • 技能可以访问插件的 packages/core 核心包" "White"
Write-ColorMessage "  • 插件始终复制到中心，删除项目后仍可用" "Cyan"
if ($pluginConfig) {
  Write-ColorMessage "  • 可在 setup.json 的 plugins 配置中启用/禁用插件" "Cyan"
}
Write-ColorMessage "`n📝 下一步:" "Yellow"
Write-ColorMessage "  1. 重启 AI 工具以加载插件技能" "White"
Write-ColorMessage "  2. 运行技能同步: .\setup.ps1" "White"
Write-ColorMessage "  3. 测试插件功能（如 /understand）`n" "White"
