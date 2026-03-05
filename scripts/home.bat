@echo off
setlocal
:: home.bat
:: Windows CMD wrapper for home.sh via WSL.

:: Check if WSL is available
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Windows Subsystem for Linux (WSL) is not found.
    echo Please install WSL to run Ansible operations on Windows.
    exit /b 1
)

:: Resolve the absolute path of home.sh (assumed to be in same dir)
set "SCRIPT_DIR=%~dp0"
set "TARGET_SCRIPT=%SCRIPT_DIR%home.sh"

:: Convert Windows path to WSL Linux path using wslpath
for /f "usebackq tokens=*" %%P in (`wsl wslpath -a "%TARGET_SCRIPT%"`) do set "LINUX_SCRIPT_PATH=%%P"

if "%LINUX_SCRIPT_PATH%"=="" (
    echo [ERROR] Failed to resolve WSL path for home.sh.
    exit /b 1
)

:: Forward execution to WSL
echo [Windows] Forwarding command to WSL...
wsl bash "%LINUX_SCRIPT_PATH%" %*
