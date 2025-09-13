@echo off
REM Medium Blog Platform - Batch wrapper for PowerShell script
REM This provides a simple batch interface to the PowerShell script

if "%1"=="" (
    echo Medium Blog Platform - Batch Interface
    echo ====================================
    echo.
    echo Usage: medium-blog.bat [command]
    echo.
    echo Commands:
    echo   setup     Run initial setup
    echo   start     Start both backend and frontend
    echo   backend   Start backend only
    echo   frontend  Start frontend only
    echo   help      Show detailed help
    echo.
    echo Examples:
    echo   medium-blog.bat setup     # First time setup
    echo   medium-blog.bat start     # Start the application
    echo   medium-blog.bat backend   # Start backend only
    echo.
    pause
    exit /b 0
)

if "%1"=="setup" (
    powershell -ExecutionPolicy Bypass -File "%~dp0medium-blog.ps1" -Setup
) else if "%1"=="start" (
    powershell -ExecutionPolicy Bypass -File "%~dp0medium-blog.ps1" -Start
) else if "%1"=="backend" (
    powershell -ExecutionPolicy Bypass -File "%~dp0medium-blog.ps1" -Backend
) else if "%1"=="frontend" (
    powershell -ExecutionPolicy Bypass -File "%~dp0medium-blog.ps1" -Frontend
) else if "%1"=="help" (
    powershell -ExecutionPolicy Bypass -File "%~dp0medium-blog.ps1" -Help
) else (
    echo Unknown command: %1
    echo Run 'medium-blog.bat' without parameters to see available commands.
    pause
    exit /b 1
)
