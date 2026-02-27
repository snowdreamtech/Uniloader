@echo off
REM ============================================================
REM Setup Python virtual environment for this project
REM ============================================================

set "SCRIPTPATH=%~dp0"
set "PROJECTROOT=%SCRIPTPATH%.."
set "VENVDIR=%PROJECTROOT%\.venv"
set "REQUIREMENTS=%PROJECTROOT%\requirements.txt"

REM Create venv if not exists
if not exist "%VENVDIR%" (
    echo Creating virtual environment in %VENVDIR%...
    python -m venv "%VENVDIR%"
    if errorlevel 1 (
        py -m venv "%VENVDIR%"
    )
)

REM Activate venv
if exist "%VENVDIR%\Scripts\activate.bat" (
    call "%VENVDIR%\Scripts\activate.bat"
) else (
    echo Error: Activation script not found at %VENVDIR%\Scripts\activate.bat
    exit /b 1
)

REM Configure pip
(
echo [global]
echo index-url = https://pypi.tuna.tsinghua.edu.cn/simple
echo trusted-host = pypi.tuna.tsinghua.edu.cn
) > "%VENVDIR%\pip.ini"

REM Install dependencies
echo Installing dependencies...
pip install -r "%REQUIREMENTS%"

REM Clear screen
cls

echo Virtual environment setup completed.
echo Venv is located at: %VENVDIR%
pause
