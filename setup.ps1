param(
  [string]$ConfigPath,
  [ValidateSet("Auto", "Link", "Copy")]
  [string]$Mode = "Auto",
  [switch]$ImportInstalledSkills,
  [switch]$SkipDoctor
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptsDir = Join-Path $repoRoot "scripts"

$scriptArgs = @{
  RepoRoot = $repoRoot
}

if ($ConfigPath) {
  $scriptArgs.ConfigPath = $ConfigPath
}

if ($ImportInstalledSkills) {
  & (Join-Path $scriptsDir "import-installed-skills.ps1") -RepoRoot $repoRoot
}

& (Join-Path $scriptsDir "build-prompts.ps1") @scriptArgs
& (Join-Path $scriptsDir "sync-skills.ps1") @scriptArgs -Mode $Mode

if (-not $SkipDoctor) {
  & (Join-Path $scriptsDir "doctor.ps1") @scriptArgs
}

Write-Host "agent-config setup complete."
