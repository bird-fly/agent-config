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
    
    # 通过技能引用关系推断来源
    if ($metadata.Sources.Count -eq 0) {
        $inferredSource = Infer-SkillSource -SkillName $Name -Content $content
        if ($inferredSource) {
            $metadata.Sources += $inferredSource.Source
            $metadata.Category = $inferredSource.Category
        }
    }
    
    if ($metadata.Sources.Count -eq 0) {
        $metadata.Sources += "未知来源"
    }
    
    return $metadata
}

function Infer-SkillSource {
    param(
        [string]$SkillName,
        [string]$Content
    )
    
    # 第一步：通过内容特征识别已知来源
    if ($Content -match 'mattpocock|matt-pocock|Matt Pocock') {
        return @{
            Source = "Matt Pocock"
            Category = "Matt Pocock"
        }
    }
    
    if ($Content -match 'anthropic|Anthropic') {
        return @{
            Source = "Anthropic"
            Category = "Anthropic"
        }
    }
    
    if ($SkillName -match '^multica-' -or $Content -match '\bmultica\b') {
        return @{
            Source = "Multica Platform"
            Category = "Multica"
        }
    }
    
    if ($Content -match 'docs/superpowers/|~/.config/superpowers/') {
        return @{
            Source = "Superpowers Framework"
            Category = "Superpowers"
        }
    }
    
    # 第二步：分析技能引用网络，通过"社群发现"推断来源
    $skillsDir = Join-Path $RepoRoot "shared\skills"
    
    # 获取所有技能及其已知来源
    $allSkills = Get-ChildItem $skillsDir -Directory | Select-Object -ExpandProperty Name
    $knownSources = @{}
    
    # 先识别所有有明确来源标识的技能
    foreach ($skill in $allSkills) {
        $skillPath = Join-Path $skillsDir "$skill\SKILL.md"
        if (Test-Path $skillPath) {
            $skillContent = Get-Content $skillPath -Raw
            
            # 检测已知来源标识
            if ($skillContent -match 'mattpocock|matt-pocock|Matt Pocock') {
                $knownSources[$skill] = "Matt Pocock"
            }
            elseif ($skillContent -match 'anthropic|Anthropic') {
                $knownSources[$skill] = "Anthropic"
            }
            elseif ($skill -match '^multica-' -or $skillContent -match '\bmultica\b') {
                $knownSources[$skill] = "Multica Platform"
            }
            elseif ($skillContent -match 'docs/superpowers/|~/.config/superpowers/') {
                $knownSources[$skill] = "Superpowers Framework"
            }
        }
    }
    
    # 分析当前技能引用了哪些其他技能
    $referencedSkills = @()
    foreach ($skill in $allSkills) {
        # 检测 /skill 格式的引用
        if ($Content -match "/$skill\b") {
            $referencedSkills += $skill
        }
    }
    
    # 统计引用的技能属于哪些来源
    $sourceCounts = @{}
    foreach ($refSkill in $referencedSkills) {
        if ($knownSources.ContainsKey($refSkill)) {
            $source = $knownSources[$refSkill]
            if (-not $sourceCounts.ContainsKey($source)) {
                $sourceCounts[$source] = 0
            }
            $sourceCounts[$source]++
        }
    }
    
    # 如果引用了某个来源的多个技能（≥2个），推断为同一来源
    $maxCount = 0
    $inferredSource = $null
    foreach ($source in $sourceCounts.Keys) {
        if ($sourceCounts[$source] -gt $maxCount) {
            $maxCount = $sourceCounts[$source]
            $inferredSource = $source
        }
    }
    
    if ($maxCount -ge 2) {
        return @{
            Source = "$inferredSource (通过技能关联推断，引用了 $maxCount 个同源技能)"
            Category = $inferredSource
        }
    }
    
    # 第三步：检查是否被其他技能引用（反向查找）
    foreach ($skill in $allSkills) {
        if ($knownSources.ContainsKey($skill)) {
            $skillPath = Join-Path $skillsDir "$skill\SKILL.md"
            if (Test-Path $skillPath) {
                $skillContent = Get-Content $skillPath -Raw
                if ($skillContent -match "/$SkillName\b") {
                    return @{
                        Source = "$($knownSources[$skill]) (被 $skill 引用)"
                        Category = $knownSources[$skill]
                    }
                }
            }
        }
    }
    
    return $null
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
