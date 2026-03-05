@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0generate_kb_entry.ps1" %*
