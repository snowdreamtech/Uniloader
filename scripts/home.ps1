<#
.SYNOPSIS
    Windows wrapper for home.sh via WSL.

.DESCRIPTION
    This script forwards home management commands (restore, decrypt, encrypt) 
    to the WSL environment, ensuring Windows users can manage secrets seamlessly.
    
    It converts the path of the home.sh script to a WSL path and executes it
    via wsl.exe.

.EXAMPLE
    .\scripts\home.ps1 restore
    .\scripts\home.ps1 decrypt -l dev_machine

#>

$ErrorActionPreference = "Stop"

# Get the directory of this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Assume home.sh is in the same directory
$HomeSh = Join-Path $ScriptDir "home.sh"

# Check if WSL is installed
if (-not (Get-Command "wsl.exe" -ErrorAction SilentlyContinue)) {
    Write-Error "WSL (Windows Subsystem for Linux) is not found. Please install WSL to run Ansible operations on Windows."
    exit 1
}

# Convert Windows path to WSL path 
$HomeShWslPath = wsl.exe wslpath -a "$HomeSh"

if (-not $HomeShWslPath) {
    Write-Error "Failed to resolve path to home.sh in WSL."
    exit 1
}

# Construct the command arguments
$WslArgs = @()
$WslArgs += $HomeShWslPath
$WslArgs += $args

# Execute inside WSL
Write-Host "[Windows] Forwarding command to WSL..." -ForegroundColor Cyan
& wsl.exe bash $WslArgs
