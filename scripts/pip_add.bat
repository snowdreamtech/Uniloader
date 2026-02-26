@echo off
REM ============================================================
REM Install Python packages and update requirements.txt (Windows CMD)
REM Usage: .\scripts\pip_add.bat <pkg1> <pkg2> ...
REM ============================================================

set "SCRIPTPATH=%~dp0"
set "PROJECTROOT=%SCRIPTPATH%.."
set "VENVDIR=%PROJECTROOT%\.venv"

REM Check if virtual environment exists
if not exist "%VENVDIR%" (
    echo Error: Virtual environment not found. Please run scripts\setup_venv.bat first.
    exit /b 1
)

REM Activate virtual environment if not already active
if "%VIRTUAL_ENV%"=="" (
    call "%VENVDIR%\Scripts\activate.bat"
)

REM Check if arguments are provided
if "%~1"=="" (
    echo Usage: .\scripts\pip_add.bat ^<pkg1^> ^<pkg2^> ...
    exit /b 0
)

REM Install packages
echo Installing dependencies: %*
pip install %*

REM Update requirements.txt
echo Updating requirements.txt...
pip freeze > "%PROJECTROOT%\requirements.txt"

echo Done! Packages installed and requirements.txt updated.
