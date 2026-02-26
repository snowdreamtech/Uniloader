# ============================================================
# Install Python packages and update requirements.txt (Windows)
# Usage: . .\scripts\pip_add.ps1 <pkg1> <pkg2> ...
# ============================================================

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
$VenvDir = Join-Path $ProjectRoot ".venv"

# Check virtual environment
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found. Please run scripts\setup_venv.ps1 first." -ForegroundColor Red
    return
}

# Activate environment
if (-not $env:VIRTUAL_ENV) {
    . (Join-Path $VenvDir "Scripts\Activate.ps1")
}

if ($args.Count -eq 0) {
    Write-Host "Usage: . .\scripts\pip_add.ps1 <pkg1> <pkg2> ..."
    return
}

# Install
Write-Host "Installing: $args" -ForegroundColor Cyan
pip install $args

# Update
Write-Host "Updating requirements.txt..." -ForegroundColor Cyan
pip freeze > (Join-Path $ProjectRoot "requirements.txt")

Write-Host "Done!" -ForegroundColor Green
