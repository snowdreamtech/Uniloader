# ============================================================
# Setup Python virtual environment for this project
# ============================================================

# Use the parent directory of this script as the project root
$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
$VenvDir = Join-Path $ProjectRoot ".venv"
$RequirementsFile = Join-Path $ProjectRoot "requirements.txt"
$PipIniFile = Join-Path $VenvDir "pip.ini"

# Create venv if not exists
if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating virtual environment in $VenvDir..." -ForegroundColor Cyan
    # Try 'python' first, then 'py'
    try {
        python -m venv $VenvDir
    } catch {
        try {
            py -0 > $null
            py -m venv $VenvDir
        } catch {
            Write-Error "Python not found. Please install Python."
            return
        }
    }
}

# Activate venv
$ActivatePath = Join-Path $VenvDir "Scripts\Activate.ps1"
if (Test-Path $ActivatePath) {
    # Check if we are dot-sourcing or running
    # If dot-sourced, the activation will persist in the caller's session
    . $ActivatePath
} else {
    Write-Error "Activation script not found at $ActivatePath"
    return
}

# Configure pip
$PipConfig = @"
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
"@

# Ensure the .venv directory exists before writing pip.ini
$PipConfig | Out-File -FilePath $PipIniFile -Encoding ascii

# Install dependencies
Write-Host "Installing dependencies from $RequirementsFile..." -ForegroundColor Cyan
pip install -r $RequirementsFile

# Clear screen
Clear-Host

Write-Host "Virtual environment setup completed." -ForegroundColor Green
Write-Host "Venv is located at: $VenvDir"
