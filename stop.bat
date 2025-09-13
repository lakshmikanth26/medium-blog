@echo off
setlocal EnableDelayedExpansion

:: Colors for Windows (limited support)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

echo %BLUE%🛑 Stopping Medium Blog Platform (Windows)%RESET%
echo.

:: Kill Java processes (Spring Boot)
echo %BLUE%🔧 Stopping Backend (Java processes)...%RESET%
taskkill /F /IM java.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✅ Backend processes stopped%RESET%
) else (
    echo %YELLOW%⚠️  No backend processes found or already stopped%RESET%
)

:: Kill Node.js processes (React)
echo %BLUE%🌐 Stopping Frontend (Node.js processes)...%RESET%
taskkill /F /IM node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✅ Frontend processes stopped%RESET%
) else (
    echo %YELLOW%⚠️  No frontend processes found or already stopped%RESET%
)

:: Also try to kill any Maven wrapper processes
taskkill /F /IM mvnw.cmd >nul 2>&1

echo.
echo %GREEN%✅ All services stopped successfully!%RESET%
echo.
echo %BLUE%📝 To start again: start.bat%RESET%
echo.

:: Optional: Clean up log files
set /p cleanup="Do you want to remove log files? (y/N): "
if /i "%cleanup%"=="y" (
    echo %BLUE%🗑️  Removing log files...%RESET%
    if exist "logs" (
        del /Q logs\*.log 2>nul
        echo %GREEN%✅ Log files removed%RESET%
    ) else (
        echo %YELLOW%ℹ️  No log files to remove%RESET%
    )
)

echo.
pause
