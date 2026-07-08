# 技能来源查询工具 - 快速版本
# 策略：使用缓存 + 简单的文本模式匹配

param(
    [Parameter(Position=0)]
    [string]$SkillName,
    
    [switch]$All,
    [switch]$BySource,
    [switch]$Interactive,
    [switch]$UpdateCache
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$CacheFile = Join-Path $RepoRoot ".gitignore.d\skill-sources.json"

function Get-SkillSourceFromCache {
    if (Test-Path $CacheFile) {
        try {
            return Get-Content $CacheFile -Raw | ConvertFrom-Json
        } catch {
            return $null
        }
    }
    return $null
}

function Build-SkillSourceCache {
    Write-Host "🔍 首次分析技能来源..." -ForegroundColor Cyan
    
    $skillsDir = Join-Path $RepoRoot "shared\skills"
    $skills = Get-ChildItem $skillsDir -Directory
    
    $cache = @{}
    
    # 已知的来源特征（通过目录名或内容特征识别）
    $patterns = @{
        "Matt Pocock" = @("ask-matt", "grill-me", "grill-with-docs", "handoff", "prototype", "triage", "to-issues", "to-prd", "tdd", "research", "teach", "codebase-design", "improve-codebase-architecture", "setup-matt-pocock-skills")
        "Multica" = @("multica-.*")
        "Anthropic" = @("find-skills", "writing-skills")
        "Superpowers" = @(".*-superpowers", "using-git-worktrees", "subagent-driven-development", "brainstorming", "finishing-a-development-branch", "requesting-code-review", "writing-plans")
    }
    
    foreach ($skill in $skills) {
        $name = $skill.Name
        $source = "未知来源"
        
        # 根据模式匹配来源
        foreach ($src in $patterns.Keys) {
            foreach ($pattern in $patterns[$src]) {
                if ($name -match "^$pattern$") {
                    $source = $src
                    break
                }
            }
            if ($source -ne "未知来源") { break }
        }
        
        # 读取描述
        $skillFile = Join-Path $skill.FullName "SKILL.md"
        $description = "N/A"
        if (Test-Path $skillFile) {
            $content = Get-Content $skillFile -Raw
            if ($content -match 'description:\s*(.+)') {
                $description = $Matches[1].Trim().Trim('"').Trim("'")
            }
        }
        
        $cache[$name] = @{
            source = $source
            description = $description
        }
    }
    
    # 保存缓存
    $cacheDir = Split-Path $CacheFile -Parent
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }
    $cache | ConvertTo-Json -Depth 3 | Set-Content $CacheFile -Encoding UTF8
    
    Write-Host "✅ 缓存已创建`n" -ForegroundColor Green
    return $cache
}

function Get-SkillInfo {
    param([string]$Name, [object]$Cache)
    
    if (-not $Cache.$Name) {
        return $null
    }
    
    return @{
        Name = $Name
        Source = $Cache.$Name.source
        Description = $Cache.$Name.description
        Category = $Cache.$Name.source
    }
}

function Show-SkillInfo {
    param($Info)
    
    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           技能详情 - $($Info.Name)".PadRight(63) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    Write-Host "📛 名称: " -NoNewline -ForegroundColor Yellow
    Write-Host $Info.Name
    
    Write-Host "📝 描述: " -NoNewline -ForegroundColor Yellow
    Write-Host $Info.Description
    
    Write-Host "📁 分类: " -NoNewline -ForegroundColor Yellow
    Write-Host $Info.Category
    
    Write-Host "📦 来源: " -NoNewline -ForegroundColor Yellow
    Write-Host $Info.Source
    
    Write-Host "📄 文档: " -NoNewline -ForegroundColor Yellow
    Write-Host "shared\skills\$($Info.Name)\SKILL.md`n"
}

# 主逻辑
$cache = Get-SkillSourceFromCache
if (-not $cache -or $UpdateCache) {
    $cache = Build-SkillSourceCache
}

if ($Interactive) {
    Write-Host "`n🔍 技能来源查询工具 (交互模式)`n" -ForegroundColor Green
    
    while ($true) {
        $skill = Read-Host "`n输入技能名称 (或 'exit' 退出)"
        
        if ($skill -eq 'exit' -or $skill -eq 'quit' -or $skill -eq '') {
            Write-Host "`n再见！`n" -ForegroundColor Green
            break
        }
        
        $info = Get-SkillInfo -Name $skill -Cache $cache
        if ($info) {
            Show-SkillInfo -Info $info
        } else {
            Write-Host "`n❌ 技能 '$skill' 不存在`n" -ForegroundColor Red
        }
    }
    exit
}

if ($All) {
    Write-Host "`n📚 所有技能来源列表`n" -ForegroundColor Green
    
    foreach ($name in $cache.PSObject.Properties.Name | Sort-Object) {
        Write-Host "$($name.PadRight(40))" -NoNewline
        Write-Host "→ " -NoNewline -ForegroundColor DarkGray
        Write-Host $cache.$name.source -ForegroundColor Cyan
    }
    
    Write-Host ""
    exit
}

if ($BySource) {
    Write-Host "`n📦 按来源分组`n" -ForegroundColor Green
    
    $groups = @{}
    foreach ($name in $cache.PSObject.Properties.Name) {
        $source = $cache.$name.source
        if (-not $groups.ContainsKey($source)) {
            $groups[$source] = @()
        }
        $groups[$source] += $name
    }
    
    foreach ($source in $groups.Keys | Sort-Object) {
        Write-Host "`n🏷️  $source" -ForegroundColor Yellow
        Write-Host ("  " + "─" * 60) -ForegroundColor DarkGray
        foreach ($skill in $groups[$source] | Sort-Object) {
            Write-Host "  • $skill" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    exit
}

if ($SkillName) {
    $info = Get-SkillInfo -Name $SkillName -Cache $cache
    if ($info) {
        Show-SkillInfo -Info $info
    } else {
        Write-Host "`n❌ 技能 '$SkillName' 不存在`n" -ForegroundColor Red
        Write-Host "使用 -All 查看所有技能列表`n"
        exit 1
    }
    exit
}

# 显示帮助
Write-Host @"

🔍 技能来源查询工具

用法:
  .\scripts\skill-source.ps1 <技能名>         查看特定技能详情
  .\scripts\skill-source.ps1 -All             列出所有技能和来源
  .\scripts\skill-source.ps1 -BySource        按来源分组显示
  .\scripts\skill-source.ps1 -Interactive     交互模式
  .\scripts\skill-source.ps1 -UpdateCache     更新缓存

示例:
  .\scripts\skill-source.ps1 grill-me
  .\scripts\skill-source.ps1 -BySource
  .\scripts\skill-source.ps1 -Interactive

性能:
  首次运行会创建缓存，后续查询瞬时响应

"@
