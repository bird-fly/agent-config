param(
  [Parameter(Mandatory = $true)]
  [string]$RepoRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PathExists {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Expected path to exist: $Path"
  }
}

function Assert-Contains {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Needle
  )

  $content = Get-Content -Raw -LiteralPath $Path
  if ($content -notlike "*$Needle*") {
    throw "Expected $Path to contain: $Needle"
  }
}

function Assert-NotContains {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Needle
  )

  $content = Get-Content -Raw -LiteralPath $Path
  if ($content -like "*$Needle*") {
    throw "Expected $Path not to contain: $Needle"
  }
}

$repoRootFull = [System.IO.Path]::GetFullPath($RepoRoot)
$testRoot = Join-Path $repoRootFull "generated/_test-targets"
$testRootFull = [System.IO.Path]::GetFullPath($testRoot)
$generatedRootFull = [System.IO.Path]::GetFullPath((Join-Path $repoRootFull "generated"))

if (-not $testRootFull.StartsWith($generatedRootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Refusing to clean unexpected test directory: $testRootFull"
}

if (Test-Path -LiteralPath $testRootFull) {
  Remove-Item -LiteralPath $testRootFull -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $testRootFull | Out-Null

$configPath = Join-Path $testRootFull "setup.test.json"
$importSourceA = Join-Path $testRootFull "installed-a"
$importSourceB = Join-Path $testRootFull "installed-b"
$importSharedSkills = Join-Path $testRootFull "shared-skills"
$importClients = Join-Path $testRootFull "clients"
$nestedWrongRoot = Join-Path $testRootFull "nested/wrong-root"
$repoLocalImportSource = Join-Path $testRootFull "repo-local-installed"
$fallbackRepoRoot = Join-Path $testRootFull "fallback-agent-config"

New-Item -ItemType Directory -Force -Path $nestedWrongRoot | Out-Null

$config = @{
  clients = @{
    codex = @{
      promptTarget = Join-Path $testRootFull "codex/AGENTS.md"
      skillsTarget = Join-Path $testRootFull "codex/skills"
    }
    claude = @{
      promptTarget = Join-Path $testRootFull "claude/CLAUDE.md"
      skillsTarget = Join-Path $testRootFull "claude/skills"
    }
    openCode = @{
      promptTarget = Join-Path $testRootFull "openCode/AGENTS.md"
      skillsTarget = Join-Path $testRootFull "openCode/skills"
    }
  }
}

$json = $config | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($configPath, $json, [System.Text.UTF8Encoding]::new($false))

$clientNames = @("codex", "claude", "openCode")
foreach ($clientName in $clientNames) {
  $clientDir = Join-Path $importClients $clientName
  New-Item -ItemType Directory -Force -Path $clientDir | Out-Null
  [System.IO.File]::WriteAllText(
    (Join-Path $clientDir "skills.manifest.json"),
    (@{ skills = @("design-taste-frontend") } | ConvertTo-Json -Depth 4),
    [System.Text.UTF8Encoding]::new($false)
  )
}

$existingSkillDir = Join-Path $importSharedSkills "design-taste-frontend"
New-Item -ItemType Directory -Force -Path $existingSkillDir | Out-Null
[System.IO.File]::WriteAllText(
  (Join-Path $existingSkillDir "SKILL.md"),
  "---`nname: design-taste-frontend`n---`n",
  [System.Text.UTF8Encoding]::new($false)
)

$alphaSkillA = Join-Path $importSourceA "import-test-alpha"
$alphaSkillB = Join-Path $importSourceB "import-test-alpha"
$duplicateExistingSkill = Join-Path $importSourceA "design-taste-frontend"
$notSkill = Join-Path $importSourceA "not-a-skill"
New-Item -ItemType Directory -Force -Path $alphaSkillA, $alphaSkillB, $duplicateExistingSkill, $notSkill | Out-Null
[System.IO.File]::WriteAllText((Join-Path $alphaSkillA "SKILL.md"), "---`nname: import-test-alpha`n---`n# Alpha A`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $alphaSkillB "SKILL.md"), "---`nname: import-test-alpha`n---`n# Alpha B`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $duplicateExistingSkill "SKILL.md"), "---`nname: design-taste-frontend`n---`n# Duplicate`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $notSkill "README.md"), "missing skill marker", [System.Text.UTF8Encoding]::new($false))

$repoLocalSkill = Join-Path $repoLocalImportSource "repo-root-fallback-test"
New-Item -ItemType Directory -Force -Path $repoLocalSkill | Out-Null
[System.IO.File]::WriteAllText((Join-Path $repoLocalSkill "SKILL.md"), "---`nname: repo-root-fallback-test`n---`n# Repo Root Fallback`n", [System.Text.UTF8Encoding]::new($false))

& (Join-Path $repoRootFull "scripts/import-installed-skills.ps1") `
  -RepoRoot $repoRootFull `
  -SourcePaths @($importSourceA, $importSourceB) `
  -SharedSkillsDir $importSharedSkills `
  -ClientsDir $importClients

$fallbackScriptsDir = Join-Path $fallbackRepoRoot "scripts"
$fallbackSharedSkillsDir = Join-Path $fallbackRepoRoot "shared/skills"
$fallbackClientsDir = Join-Path $fallbackRepoRoot "clients"
New-Item -ItemType Directory -Force -Path $fallbackScriptsDir, $fallbackSharedSkillsDir | Out-Null
Copy-Item -LiteralPath (Join-Path $repoRootFull "scripts/import-installed-skills.ps1") -Destination (Join-Path $fallbackScriptsDir "import-installed-skills.ps1") -Force
foreach ($clientName in $clientNames) {
  $clientDir = Join-Path $fallbackClientsDir $clientName
  New-Item -ItemType Directory -Force -Path $clientDir | Out-Null
  [System.IO.File]::WriteAllText(
    (Join-Path $clientDir "skills.manifest.json"),
    (@{ skills = @() } | ConvertTo-Json -Depth 4),
    [System.Text.UTF8Encoding]::new($false)
  )
}

& (Join-Path $fallbackScriptsDir "import-installed-skills.ps1") `
  -RepoRoot $nestedWrongRoot `
  -SourcePaths @($repoLocalImportSource)

Assert-PathExists (Join-Path $fallbackRepoRoot "shared/skills/repo-root-fallback-test/SKILL.md")

Assert-PathExists (Join-Path $importSharedSkills "import-test-alpha/SKILL.md")
Assert-Contains (Join-Path $importSharedSkills "import-test-alpha/SKILL.md") "Alpha A"
Assert-Contains (Join-Path $importSharedSkills "design-taste-frontend/SKILL.md") "name: design-taste-frontend"

foreach ($clientName in $clientNames) {
  $manifestPath = Join-Path $importClients "$clientName/skills.manifest.json"
  Assert-Contains $manifestPath "import-test-alpha"
  $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
  $alphaCount = @($manifest.skills | Where-Object { $_ -eq "import-test-alpha" }).Count
  if ($alphaCount -ne 1) {
    throw "Expected import-test-alpha once in $manifestPath, found $alphaCount"
  }
}

& (Join-Path $repoRootFull "scripts/build-prompts.ps1") -RepoRoot $repoRootFull -ConfigPath $configPath
& (Join-Path $repoRootFull "scripts/sync-skills.ps1") -RepoRoot $repoRootFull -ConfigPath $configPath -Mode Copy
& (Join-Path $repoRootFull "scripts/doctor.ps1") -RepoRoot $repoRootFull -ConfigPath $configPath

$codexGenerated = Join-Path $repoRootFull "generated/codex/AGENTS.md"
$claudeGenerated = Join-Path $repoRootFull "generated/claude/CLAUDE.md"
$openCodeGenerated = Join-Path $repoRootFull "generated/openCode/AGENTS.md"

Assert-PathExists $codexGenerated
Assert-PathExists $claudeGenerated
Assert-PathExists $openCodeGenerated
Assert-Contains $codexGenerated "双模式智能切换"
Assert-Contains $claudeGenerated "Skill 使用总则"
Assert-Contains $openCodeGenerated "Windows shell 输出中文异常"
Assert-Contains $codexGenerated "Codex 专属规则"
Assert-Contains $claudeGenerated "Claude Code 专属规则"
Assert-Contains $openCodeGenerated "openCode 专属规则"
Assert-NotContains $codexGenerated "Client Notes"
Assert-NotContains $claudeGenerated "Client Notes"
Assert-NotContains $openCodeGenerated "Client Notes"

$codexSkill = Join-Path $testRootFull "codex/skills/design-taste-frontend/SKILL.md"
$claudeSkill = Join-Path $testRootFull "claude/skills/design-taste-frontend/SKILL.md"
Assert-PathExists $codexSkill
Assert-PathExists $claudeSkill
Assert-Contains $codexSkill "FINAL PRE-FLIGHT CHECK"
Assert-Contains $claudeSkill "Anti-Slop Frontend Skill"

Assert-PathExists (Join-Path $testRootFull "codex/AGENTS.md")
Assert-PathExists (Join-Path $testRootFull "claude/CLAUDE.md")

Write-Host "agent-config script tests passed."
