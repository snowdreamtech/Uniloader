# ============================================================
# PowerShell venv manager
# Usage: . .\scripts\venv.ps1 <command>
# Commands:
#   on        Activate venv
#   off       Deactivate venv
#   recreate  Recreate venv
#   status    Show venv status
#   path      Show venv path
# ============================================================

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
$VenvDir = Join-Path $ProjectRoot ".venv"

function venv_on {
    if (-not (Test-Path $VenvDir)) {
        Write-Host "Virtual environment not found. Creating..." -ForegroundColor Cyan
        python -m venv $VenvDir
    }
    . (Join-Path $VenvDir "Scripts\Activate.ps1")
    Write-Host "Venv activated." -ForegroundColor Green
}

function venv_off {
    if (Get-Command deactivate -ErrorAction SilentlyContinue) {
        deactivate
        Write-Host "Venv deactivated." -ForegroundColor Yellow
    } else {
        Write-Host "Venv is not active." -ForegroundColor Gray
    }
}

function venv_recreate {
    Write-Host "Recreating venv..." -ForegroundColor Cyan
    if (Test-Path $VenvDir) {
        Remove-Item -Recurse -Force $VenvDir
    }
    python -m venv $VenvDir
    Write-Host "Venv recreated." -ForegroundColor Green
}

function venv_status {
    if ($env:VIRTUAL_ENV) {
        Write-Host "Venv is active." -ForegroundColor Green
    } else {
        Write-Host "Venv is not active." -ForegroundColor Gray
    }
}

function venv_path {
    Write-Host $VenvDir
}

switch ($args[0]) {
    "on" { venv_on }
    "off" { venv_off }
    "recreate" { venv_recreate }
    "status" { venv_status }
    "path" { venv_path }
    default {
        Write-Host "Usage: . .\scripts\venv.ps1 {on|off|recreate|status|path}"
    }
}
