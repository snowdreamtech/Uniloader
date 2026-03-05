@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0validate_image_database.ps1" %*
