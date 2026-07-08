param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = $PWD,
  
  [Parameter(Mandatory = $false)]
  [string]$PluginCenterPath = "$env:USERPROFILE\.localAIPlugins",
  
  [Parameter(Mandatory = $false)]
  [ValidateSet("Link", "Copy")]
  [string]$Mode = "Link"
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

function Link-PluginToPlatform {
  param(
    [string]$PlatformName,
    [string]$PlatformPath,
    [string]$PluginName,
    [string]$CenterPath
  )
  
  if (-not (Test-Path $PlatformPath)) {
    return
  }
  
  $sourcePath = Join-Path $CenterPath $PluginName
  $targetPath = Join-Path $PlatformPath $PluginName
  
  if (-not (Test-Path $sourcePath)) {
    return
  }
  
  # 如果已存在，检查是否已经是正确的链接
  if (Test-Path $targetPath) {
    $item = Get-Item $targetPath
    if ($item.LinkType -eq "Junction" -and $item.Target -eq $sourcePath) {
      return
    }
    Remove-Item -Recurse -Force $targetPath
  }
  
  # 创建符号链接
  try {
    cmd /c mklink /J "$targetPath" "$sourcePath" | Out-Null
    Write-ColorMessage "    ✓ $PlatformName" "Gray"
  } catch {
    Write-ColorMessage "    ✗ $PlatformName (失败)" "Red"
  }
}

# 主逻辑
Write-ColorMessage "`n🔌 插件统一管理系统" "Cyan"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$repoRootFull = [System.IO.Path]::GetFullPath($RepoRoot)
$pluginsSourceDir = Join-Path $repoRootFull "shared\plugins"
$pluginCenterFull = [System.IO.Path]::GetFullPath($PluginCenterPath)

# 创建插件中心目录
if (-not (Test-Path $pluginCenterFull)) {
  Write-ColorMessage "📁 创建插件中心: $pluginCenterFull" "Cyan"
  New-Item -ItemType Directory -Force -Path $pluginCenterFull | Out-Null
}

Write-ColorMessage "📂 插件源: $pluginsSourceDir" "Gray"
Write-ColorMessage "📦 插件中心: $pluginCenterFull" "Gray"
Write-ColorMessage "🔗 同步模式: $Mode`n" "Gray"

# 步骤 1: 同步插件到中心
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 1: 同步插件到中心" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

if (-not (Test-Path $pluginsSourceDir)) {
  Write-ColorMessage "❌ 错误：插件源目录不存在" "Red"
  exit 1
}

$syncedPlugins = @()
$pluginDirs = Get-ChildItem -Path $pluginsSourceDir -Directory

foreach ($pluginDir in $pluginDirs) {
  $pluginName = $pluginDir.Name
  
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
                                 -SyncMode $Mode
  
  if ($synced) {
    $syncedPlugins += $pluginName
  }
}

if ($syncedPlugins.Count -eq 0) {
  Write-ColorMessage "`n⚠️  没有插件被同步" "Yellow"
  exit 0
}

# 步骤 2: 链接到各平台
Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "步骤 2: 链接到各平台" "Yellow"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$platforms = @(
  @{Name="Claude"; Path="$env:USERPROFILE\.claude"},
  @{Name="Codex"; Path="$env:USERPROFILE\.codex"},
  @{Name="OpenCode"; Path="$env:USERPROFILE\.openCode"}
)

foreach ($pluginName in $syncedPlugins) {
  Write-ColorMessage "  ${pluginName}:" "Cyan"
  
  foreach ($platform in $platforms) {
    Link-PluginToPlatform -PlatformName $platform.Name `
                          -PlatformPath $platform.Path `
                          -PluginName $pluginName `
                          -CenterPath $pluginCenterFull
  }
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
Write-ColorMessage "  • 插件中心: $pluginCenterFull" "White"
Write-ColorMessage "  • 链接平台: Claude, Codex, OpenCode`n" "White"

Write-ColorMessage "📝 下一步:" "Yellow"
Write-ColorMessage "  1. 重启 AI 工具以加载插件" "White"
Write-ColorMessage "  2. 运行技能同步: .\setup.ps1" "White"
Write-ColorMessage "  3. 测试插件功能`n" "White"
