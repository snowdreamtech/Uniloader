<#
.SYNOPSIS
    Windows wrapper for Ansible Vault operations via WSL.

.DESCRIPTION
    This script forwards vault commands to the WSL environment, ensuring 
    Windows users can manage secrets seamlessly without manually entering WSL.
    
    It converts the path of the vault.sh script to a WSL path and executes it
    via wsl.exe.

.EXAMPLE
    .\scripts\vault.ps1 edit
    .\scripts\vault.ps1 encrypt_string 'password' --name 'db_password'

#>

$ErrorActionPreference = "Stop"

# Get the directory of this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Assume vault.sh is in the same directory
$VaultSh = Join-Path $ScriptDir "vault.sh"

# Check if WSL is installed
if (-not (Get-Command "wsl.exe" -ErrorAction SilentlyContinue)) {
    Write-Error "WSL (Windows Subsystem for Linux) is not found. Please install WSL to run Ansible operations on Windows."
    exit 1
}

# Convert Windows path to WSL path 
# (Simple conversion mapping C:\ -> /mnt/c/)
# Note: wslpath tool inside wsl is more robust, but implies spinning up wsl once.
$VaultShWslPath = wsl.exe wslpath -a "$VaultSh"

if (-not $VaultShWslPath) {
    Write-Error "Failed to resolve path to vault.sh in WSL."
    exit 1
}

# Construct the command arguments
# passing all arguments received by this script
$WslArgs = @()
$WslArgs += $VaultShWslPath
$WslArgs += $args

# Execute inside WSL
Write-Host "[Windows] Forwarding command to WSL..." -ForegroundColor Cyan
& wsl.exe bash $WslArgs
