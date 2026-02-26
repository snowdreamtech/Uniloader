@echo off
REM ============================================================
REM Batch venv manager
REM Usage: .\scripts\venv.bat <command>
REM Commands:
REM   on        Activate venv
REM   off       Deactivate venv
REM   recreate  Recreate venv
REM   status    Show venv status
REM   path      Show venv path
REM ============================================================

set "SCRIPTPATH=%~dp0"
set "PROJECTROOT=%SCRIPTPATH%.."
set "VENVDIR=%PROJECTROOT%\.venv"

if "%~1"=="on" goto venv_on
if "%~1"=="off" goto venv_off
if "%~1"=="recreate" goto venv_recreate
if "%~1"=="status" goto venv_status
if "%~1"=="path" goto venv_path

echo Usage: .\scripts\venv.bat {on^|off^|recreate^|status^|path}
goto :EOF

:venv_on
if not exist "%VENVDIR%" (
    echo Virtual environment not found. Creating...
    python -m venv "%VENVDIR%"
)
call "%VENVDIR%\Scripts\activate.bat"
echo Venv activated.
goto :EOF

:venv_off
if defined VIRTUAL_ENV (
    call "%VENVDIR%\Scripts\deactivate.bat"
    echo Venv deactivated.
) else (
    echo Venv is not active.
)
goto :EOF

:venv_recreate
echo Recreating venv...
if exist "%VENVDIR%" rd /s /q "%VENVDIR%"
python -m venv "%VENVDIR%"
echo Venv recreated.
goto :EOF

:venv_status
if defined VIRTUAL_ENV (
    echo Venv is active.
) else (
    echo Venv is not active.
)
goto :EOF

:venv_path
echo %VENVDIR%
goto :EOF
