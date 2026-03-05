@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0detect_image_uid.ps1" %*
