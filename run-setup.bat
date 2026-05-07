@echo off

title Insight Server Setup

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-server.ps1"

echo.
pause