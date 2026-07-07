# 技能来源查询工具
# 用途: 快速查询技能的来源和归属

param(
    [Parameter(Position=0)]
    [string]$SkillName,
    
    [switch]$All,
    [switch]$BySource,
    [switch]$Interactive
)

$RepoRoot = Split-Path -Parent $PSScriptRoot

function Get-SkillMetadata {
    param([string]$Name)
    
    $skillPath = Join-Path $RepoRoot "shared\skills\$Name\SKILL.md"
    
    if (-not (Test-Path $skillPath)) {
        return $null
    }
    
    $content = Get-Content $skillPath -Raw
    
    # 提取 YAML frontmatter
    $metadata = @{
        Name = $Name
        Description = "N/A"
        Sources = @()
        Category = "未分类"
    }
    
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $yaml = $Matches[1]
        if ($yaml -match 'description:\s*(.+)') {
            $metadata.Description = $Matches[1].Trim().Trim('"').Trim("'")
        }
        if ($yaml -match 'author:\s*(.+)') {
            $metadata.Sources += "作者: $($Matches[1].Trim())"
        }
    }
    
    # 检测来源标识
    if ($content -match 'mattpocock|matt-pocock|Matt Pocock') {
        $metadata.Sources += "Matt Pocock"
        $metadata.Category = "Matt Pocock"
    }
    
    if ($content -match 'anthropic|Anthropic') {
        $metadata.Sources += "Anthropic"
    }
    
    if ($content -match 'docs/superpowers/|~/.config/superpowers/') {
        $metadata.Sources += "Superpowers Framework"
        $metadata.Category = "Superpowers"
    }
    
    if ($Name -match '^multica-' -or $content -match 'multica') {
        $metadata.Sources += "Multica Platform"
        $metadata.Category = "Multica"
    }
    
    if ($content -match 'github\.com/([^/\s]+/[^/\s]+)') {
        $metadata.Sources += "GitHub: $($Matches[1])"
    }
    
    if ($metadata.Sources.Count -eq 0) {
        $metadata.Sources += "未知来源"
    }
    
    return $metadata
}

function Show-SkillInfo {
    param($Metadata)
    
    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           技能详情 - $($Metadata.Name)".PadRight(63) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    Write-Host "📛 名称: " -NoNewline -ForegroundColor Yellow
    Write-Host $Metadata.Name
    
    Write-Host "📝 描述: " -NoNewline -ForegroundColor Yellow
    Write-Host $Metadata.Description
    
    Write-Host "📁 分类: " -NoNewline -ForegroundColor Yellow
    Write-Host $Metadata.Category
    
    Write-Host "📦 来源: " -NoNewline -ForegroundColor Yellow
    Write-Host ($Metadata.Sources -join ', ')
    
    Write-Host "📄 文档: " -NoNewline -ForegroundColor Yellow
    Write-Host "shared\skills\$($Metadata.Name)\SKILL.md`n"
}

# 主逻辑
if ($Interactive) {
    Write-Host "`n🔍 技能来源查询工具 (交互模式)`n" -ForegroundColor Green
    
    while ($true) {
        $skill = Read-Host "`n输入技能名称 (或 'exit' 退出)"
        
        if ($skill -eq 'exit' -or $skill -eq 'quit' -or $skill -eq '') {
            Write-Host "`n再见！`n" -ForegroundColor Green
            break
        }
        
        $meta = Get-SkillMetadata -Name $skill
        if ($meta) {
            Show-SkillInfo -Metadata $meta
        } else {
            Write-Host "`n❌ 技能 '$skill' 不存在`n" -ForegroundColor Red
        }
    }
    exit
}

if ($All) {
    Write-Host "`n📚 所有技能来源列表`n" -ForegroundColor Green
    
    $skillsDir = Join-Path $RepoRoot "shared\skills"
    $skills = Get-ChildItem $skillsDir -Directory | Select-Object -ExpandProperty Name
    
    foreach ($skill in $skills | Sort-Object) {
        $meta = Get-SkillMetadata -Name $skill
        if ($meta) {
            Write-Host "$($skill.PadRight(40))" -NoNewline
            Write-Host "→ " -NoNewline -ForegroundColor DarkGray
            Write-Host ($meta.Sources -join ', ') -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    exit
}

if ($BySource) {
    Write-Host "`n📦 按来源分组`n" -ForegroundColor Green
    
    $skillsDir = Join-Path $RepoRoot "shared\skills"
    $skills = Get-ChildItem $skillsDir -Directory | Select-Object -ExpandProperty Name
    
    $sourceGroups = @{}
    
    foreach ($skill in $skills) {
        $meta = Get-SkillMetadata -Name $skill
        if ($meta) {
            foreach ($source in $meta.Sources) {
                if (-not $sourceGroups.ContainsKey($source)) {
                    $sourceGroups[$source] = @()
                }
                $sourceGroups[$source] += $skill
            }
        }
    }
    
    foreach ($source in $sourceGroups.Keys | Sort-Object) {
        Write-Host "`n🏷️  $source" -ForegroundColor Yellow
        Write-Host ("  " + "─" * 60) -ForegroundColor DarkGray
        foreach ($skill in $sourceGroups[$source] | Sort-Object) {
            Write-Host "  • $skill" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    exit
}

if ($SkillName) {
    $meta = Get-SkillMetadata -Name $SkillName
    if ($meta) {
        Show-SkillInfo -Metadata $meta
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

示例:
  .\scripts\skill-source.ps1 grill-me
  .\scripts\skill-source.ps1 -BySource
  .\scripts\skill-source.ps1 -Interactive

"@
