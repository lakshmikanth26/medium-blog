@echo off
setlocal EnableDelayedExpansion

:: Colors for Windows (limited support)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

echo %BLUE%🚀 Starting Medium Blog Platform (Windows)%RESET%
echo.

:: Check if running in correct directory
if not exist "backend" (
    echo %RED%❌ Backend directory not found! Please run this script from the project root.%RESET%
    pause
    exit /b 1
)

if not exist "frontend" (
    echo %RED%❌ Frontend directory not found! Please run this script from the project root.%RESET%
    pause
    exit /b 1
)

:: Create logs directory
if not exist "logs" mkdir logs

echo %BLUE%🗄️  Checking MongoDB...%RESET%
netstat -an | find "LISTENING" | find ":27017" >nul
if %errorlevel% neq 0 (
    echo %YELLOW%⚠️  MongoDB is not running on port 27017%RESET%
    echo Please start MongoDB manually:
    echo   - Install MongoDB Community Server: https://www.mongodb.com/try/download/community
    echo   - Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0
    echo.
    echo Press any key to continue anyway, or Ctrl+C to cancel...
    pause > nul
)

echo %BLUE%🔧 Starting Spring Boot Backend...%RESET%

:: Navigate to backend directory
pushd backend
if %errorlevel% neq 0 (
    echo %RED%❌ Could not enter backend directory!%RESET%
    pause
    exit /b 1
)

:: Determine Maven command
set "MAVEN_CMD="
if exist ".mvn\wrapper\maven-wrapper.jar" (
    echo Using Maven wrapper...
    set "MAVEN_CMD=mvnw.cmd"
) else if exist "mvnw.cmd" (
    echo Maven wrapper jar missing, using mvnw.cmd...
    set "MAVEN_CMD=mvnw.cmd"
) else (
    where mvn >nul 2>&1
    if %errorlevel% equ 0 (
        echo Using system Maven...
        set "MAVEN_CMD=mvn"
    ) else (
        echo %RED%❌ Neither Maven wrapper nor system Maven is available!%RESET%
        echo Please install Maven or run setup.bat first.
        popd
        pause
        exit /b 1
    )
)

:: Start backend in background
echo Starting backend with !MAVEN_CMD!...
start "Backend Server" /MIN !MAVEN_CMD! spring-boot:run

popd

:: Wait a moment for backend to initialize
echo %BLUE%⏳ Waiting for backend to start...%RESET%
timeout /t 5 >nul

echo %BLUE%🌐 Starting React Frontend...%RESET%

:: Navigate to frontend directory
pushd frontend
if %errorlevel% neq 0 (
    echo %RED%❌ Could not enter frontend directory!%RESET%
    pause
    exit /b 1
)

:: Check if node_modules exists
if not exist "node_modules" (
    echo %YELLOW%⚠️  node_modules not found, running npm install...%RESET%
    npm install
    if %errorlevel% neq 0 (
        echo %RED%❌ Failed to install frontend dependencies!%RESET%
        echo Please run setup.bat first.
        popd
        pause
        exit /b 1
    )
)

:: Start frontend
echo Starting frontend...
start "Frontend Server" npm start

popd

echo.
echo %GREEN%🎉 Medium Blog Platform is starting!%RESET%
echo.
echo %GREEN%🌐 Frontend: http://localhost:3000%RESET%
echo %GREEN%🔧 Backend API: http://localhost:8080/api%RESET%
echo %GREEN%🗄️  Database: MongoDB on localhost:27017%RESET%
echo.
echo %BLUE%📚 Sample Login Credentials:%RESET%
echo   Username: john_doe ^| Password: demo123
echo   Username: jane_smith ^| Password: demo123
echo.
echo %YELLOW%⚠️  Both servers are starting in separate windows.%RESET%
echo %YELLOW%⚠️  Close those windows to stop the servers.%RESET%
echo.
echo %BLUE%ℹ️  To stop all services, run: stop.bat%RESET%
echo.
echo Press any key to exit this script (servers will keep running)...
pause > nul
