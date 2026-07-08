param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("codex", "openCode", "all")]
  [string]$Platform = "all",
  
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = $PWD
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

function Install-PluginToPlatform {
  param(
    [string]$PlatformName,
    [string]$PlatformPath,
    [string]$PluginSourcePath
  )
  
  Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
  Write-ColorMessage "安装到 $PlatformName" "Yellow"
  Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
  
  if (-not (Test-Path $PlatformPath)) {
    Write-ColorMessage "  ⚠️  $PlatformName 目录不存在，跳过" "Yellow"
    return
  }
  
  $pluginTargetPath = Join-Path $PlatformPath "understand-anything"
  
  # 检查是否已存在
  if (Test-Path $pluginTargetPath) {
    Write-ColorMessage "  🔄 插件已存在，将被覆盖" "Yellow"
    Remove-Item -Recurse -Force $pluginTargetPath
  }
  
  # 创建符号链接指向插件源
  Write-ColorMessage "  📦 创建符号链接..." "Cyan"
  try {
    cmd /c mklink /J "$pluginTargetPath" "$PluginSourcePath" | Out-Null
    Write-ColorMessage "  ✅ 插件安装成功 (Junction 符号链接)" "Green"
    Write-ColorMessage "     源: $PluginSourcePath" "Gray"
    Write-ColorMessage "     目标: $pluginTargetPath" "Gray"
  } catch {
    Write-ColorMessage "  ⚠️  无法创建符号链接，尝试复制..." "Yellow"
    Copy-Item -Recurse -Force $PluginSourcePath $pluginTargetPath
    Write-ColorMessage "  ✅ 插件安装成功 (复制)" "Green"
  }
  
  # 验证安装
  $agentsPath = Join-Path $pluginTargetPath "agents"
  $hooksPath = Join-Path $pluginTargetPath "hooks"
  $skillsPath = Join-Path $pluginTargetPath "skills"
  $packagesPath = Join-Path $pluginTargetPath "packages"
  
  Write-ColorMessage "`n  📊 组件验证:" "Cyan"
  Write-ColorMessage "     Agents:   $(if(Test-Path $agentsPath){'✅'}else{'❌'})" "Gray"
  Write-ColorMessage "     Hooks:    $(if(Test-Path $hooksPath){'✅'}else{'❌'})" "Gray"
  Write-ColorMessage "     Skills:   $(if(Test-Path $skillsPath){'✅'}else{'❌'})" "Gray"
  Write-ColorMessage "     Packages: $(if(Test-Path $packagesPath){'✅'}else{'❌'})" "Gray"
}

# 主逻辑
Write-ColorMessage "`n🔌 Understand-Anything 插件完整安装" "Cyan"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

$repoRootFull = [System.IO.Path]::GetFullPath($RepoRoot)
$pluginSource = Join-Path $repoRootFull "shared\plugins\understand-anything\understand-anything-plugin"

# 验证插件源
if (-not (Test-Path $pluginSource)) {
  Write-ColorMessage "❌ 错误：找不到插件源目录" "Red"
  Write-ColorMessage "   预期位置: $pluginSource" "Gray"
  exit 1
}

Write-ColorMessage "📂 插件源: $pluginSource`n" "Gray"

# 安装到各平台
$platforms = @(
  @{Name="Codex"; Path="$env:USERPROFILE\.codex"},
  @{Name="OpenCode"; Path="$env:USERPROFILE\.openCode"}
)

foreach ($p in $platforms) {
  if ($Platform -eq "all" -or $Platform -eq $p.Name.ToLower()) {
    Install-PluginToPlatform -PlatformName $p.Name -PlatformPath $p.Path -PluginSourcePath $pluginSource
  }
}

Write-ColorMessage "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-ColorMessage "✅ 安装完成！" "Green"
Write-ColorMessage "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" "Cyan"

Write-ColorMessage "📝 下一步：" "Yellow"
Write-ColorMessage "   1. 重启 $Platform" "White"
Write-ColorMessage "   2. 运行 /understand 测试插件功能" "White"
Write-ColorMessage "   3. 技能已通过 setup.ps1 同步，无需额外操作`n" "White"
