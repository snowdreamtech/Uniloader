<#
.SYNOPSIS
    Windows smart wrapper for pip_add.sh.
#>

$ErrorActionPreference = "Stop"

# Detect Environment
$EnvType = $null
$BashBin = $null
$PathRegex = "^@?[A-Za-z]:[\\/]"

if (Get-Command "wsl.exe" -ErrorAction SilentlyContinue) {
    $EnvType = "wsl"
    $BashBin = "wsl"
} elseif (Get-Command "bash.exe" -ErrorAction SilentlyContinue) {
    $EnvType = "gitbash"
    $BashBin = "bash"
} else {
    Write-Host "[ERROR] Environment missing: WSL (Windows Subsystem for Linux) or Git Bash not found." -ForegroundColor Red
    Write-Host "Ansible requires a POSIX-compatible environment to run on Windows.`n"
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host " Recommended Solution (Install WSL):" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host " Open PowerShell as Administrator and run:"
    Write-Host "     wsl --install"
    Write-Host " Restart your computer after installation.`n"
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host " Alternative Solution (Install Git Bash):" -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host " Download and install Git for Windows from:"
    Write-Host "     https://gitforwindows.org/"
    Write-Host "==========================================================" -ForegroundColor Yellow
    exit 1
}

# Resolve target script path
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
$TargetScript = Join-Path $ScriptDir "$BaseName.sh"

Function Convert-ToPosixPath {
    param([string]$WinPath)

    $Prefix = ""
    $ActualPath = $WinPath
    if ($WinPath -match "^@") {
        $Prefix = "@"
        $ActualPath = $WinPath.Substring(1)
    }

    if ($EnvType -eq "wsl") {
        # wslpath requires -m or -u for non-existent strings, but -u works best
        $Converted = wsl.exe wslpath -u $ActualPath
        if ($LASTEXITCODE -eq 0 -and $Converted) { return $Prefix + $Converted }
    } elseif ($EnvType -eq "gitbash") {
        $WinPathFwd = $ActualPath -replace "\\", "/"
        $Converted = bash.exe -c "cygpath -u '$WinPathFwd'"
        if ($LASTEXITCODE -eq 0 -and $Converted) { return $Prefix + $Converted }
    }
    return $WinPath
}

$LinuxScriptPath = Convert-ToPosixPath $TargetScript

if ([string]::IsNullOrWhiteSpace($LinuxScriptPath)) {
    Write-Error "Failed to resolve POSIX path for $BaseName.sh."
    exit 1
}

$ForwardArgs = @()
if ($EnvType -eq "wsl") {
    $ForwardArgs += "bash"
}
$ForwardArgs += $LinuxScriptPath

foreach ($arg in $args) {
    if ($arg -match $PathRegex) {
        $ForwardArgs += Convert-ToPosixPath $arg
    } else {
        $ForwardArgs += $arg
    }
}

Write-Host "[Windows] Smart forwarding to $EnvType..." -ForegroundColor DarkGray
& $BashBin $ForwardArgs
exit $LASTEXITCODE
