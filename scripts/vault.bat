@echo off
setlocal
:: vault.bat
:: Windows CMD wrapper for Ansible Vault operations via WSL.

:: Check if WSL is available
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Windows Subsystem for Linux (WSL) is not found.
    echo Please install WSL to run Ansible operations on Windows.
    exit /b 1
)

:: Resolve the absolute path of vault.sh (assumed to be in same dir)
set "SCRIPT_DIR=%~dp0"
set "TARGET_SCRIPT=%SCRIPT_DIR%vault.sh"

:: Convert Windows path to WSL Linux path using wslpath
:: We use a temporary command to capture output
for /f "usebackq tokens=*" %%P in (`wsl wslpath -a "%TARGET_SCRIPT%"`) do set "LINUX_SCRIPT_PATH=%%P"

if "%LINUX_SCRIPT_PATH%"=="" (
    echo [ERROR] Failed to resolve WSL path for vault.sh.
    exit /b 1
)

:: Forward execution to WSL
:: %* passes all arguments provided to this batch file
echo [Windows] Forwarding command to WSL...
wsl bash "%LINUX_SCRIPT_PATH%" %*
