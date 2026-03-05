@echo off
setlocal
:: Windows CMD wrapper that delegates to the PowerShell implementation.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dpn0.ps1" %*
exit /b %errorlevel%
