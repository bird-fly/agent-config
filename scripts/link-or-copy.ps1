param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [Parameter(Mandatory = $true)]
  [string]$Destination,
  [ValidateSet("Auto", "Link", "Copy")]
  [string]$Mode = "Auto"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullPath {
  param([Parameter(Mandatory = $true)][string]$Path)
  $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)
  return [System.IO.Path]::GetFullPath($expandedPath)
}

function Assert-SafeDestination {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = Get-FullPath $Path
  $root = [System.IO.Path]::GetPathRoot($fullPath)
  $leaf = Split-Path -Leaf $fullPath

  if ([string]::IsNullOrWhiteSpace($leaf)) {
    throw "Destination must not be a drive root: $fullPath"
  }

  if ($fullPath -eq $root) {
    throw "Destination must not be a drive root: $fullPath"
  }
}

function Remove-Destination {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  Assert-SafeDestination $Path
  Remove-Item -LiteralPath $Path -Recurse -Force
}

function Copy-Source {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath
  )

  Remove-Destination $DestinationPath
  $parent = Split-Path -Parent $DestinationPath
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Recurse -Force
  return "Copy"
}

function Link-Source {
  param(
    [Parameter(Mandatory = $true)][string]$SourcePath,
    [Parameter(Mandatory = $true)][string]$DestinationPath
  )

  Remove-Destination $DestinationPath
  $parent = Split-Path -Parent $DestinationPath
  if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  $sourceItem = Get-Item -LiteralPath $SourcePath
  if ($sourceItem.PSIsContainer) {
    New-Item -ItemType Junction -Path $DestinationPath -Target $SourcePath | Out-Null
  } else {
    New-Item -ItemType HardLink -Path $DestinationPath -Target $SourcePath | Out-Null
  }

  return "Link"
}

$sourceFull = Get-FullPath $Source
$destinationFull = Get-FullPath $Destination

if (-not (Test-Path -LiteralPath $sourceFull)) {
  throw "Source does not exist: $sourceFull"
}

Assert-SafeDestination $destinationFull

if ($sourceFull -eq $destinationFull) {
  [pscustomobject]@{
    mode = "SamePath"
    source = $sourceFull
    destination = $destinationFull
  }
  return
}

$selectedMode = $null
if ($Mode -eq "Copy") {
  $selectedMode = Copy-Source -SourcePath $sourceFull -DestinationPath $destinationFull
} elseif ($Mode -eq "Link") {
  $selectedMode = Link-Source -SourcePath $sourceFull -DestinationPath $destinationFull
} else {
  try {
    $selectedMode = Link-Source -SourcePath $sourceFull -DestinationPath $destinationFull
  } catch {
    Write-Host "Link failed for $destinationFull; falling back to copy. $($_.Exception.Message)"
    $selectedMode = Copy-Source -SourcePath $sourceFull -DestinationPath $destinationFull
  }
}

[pscustomobject]@{
  mode = $selectedMode
  source = $sourceFull
  destination = $destinationFull
}
