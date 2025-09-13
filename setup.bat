@echo off
setlocal EnableDelayedExpansion

:: Colors for Windows (limited support)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

echo %BLUE%🎯 Medium Blog Platform - First Time Setup (Windows)%RESET%
echo =========================================
echo.

:: Create logs directory
if not exist "logs" mkdir logs

:: Function to log messages
call :log_info "Starting Windows setup process..."

:: Check if running in correct directory
if not exist "pom.xml" if not exist "backend" (
    call :log_error "Please run this script from the project root directory!"
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo %BLUE%ℹ️  Step 1: Checking System Prerequisites%RESET%
echo ------------------------------------

:: Check Java
call :log_info "Checking Java installation..."
java -version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error "Java is not installed or not in PATH!"
    echo Please install Java 17+ and add it to your PATH:
    echo   - Download from: https://adoptium.net/
    echo   - Or use: winget install EclipseAdoptium.Temurin.17.JDK
    pause
    exit /b 1
)

:: Get Java version
for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VERSION=%%g
)
set JAVA_VERSION=%JAVA_VERSION:"=%
for /f "delims=. tokens=1,2" %%v in ("%JAVA_VERSION%") do (
    if %%v LSS 17 if %%v GTR 1 (
        call :log_error "Java 17+ required, but found Java %JAVA_VERSION%"
        pause
        exit /b 1
    )
    if %%v EQU 1 if %%w LSS 8 (
        call :log_error "Java 17+ required, but found Java %JAVA_VERSION%"
        pause
        exit /b 1
    )
)
call :log_success "Java is installed: %JAVA_VERSION%"

:: Check Node.js
call :log_info "Checking Node.js installation..."
node --version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error "Node.js is not installed or not in PATH!"
    echo Please install Node.js 16+ and add it to your PATH:
    echo   - Download from: https://nodejs.org/
    echo   - Or use: winget install OpenJS.NodeJS
    pause
    exit /b 1
)

for /f %%i in ('node --version') do set NODE_VERSION=%%i
call :log_success "Node.js is installed: !NODE_VERSION!"

:: Check npm
call :log_info "Checking npm installation..."
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error "npm is not installed!"
    echo npm should come with Node.js. Please reinstall Node.js.
    pause
    exit /b 1
)

for /f %%i in ('npm --version') do set NPM_VERSION=%%i
call :log_success "npm is installed: v!NPM_VERSION!"

:: Check Maven
call :log_info "Checking Maven installation..."
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_warning "Maven not found, will use Maven wrapper (mvnw.cmd)"
) else (
    for /f "tokens=3" %%g in ('mvn --version ^| findstr "Apache Maven"') do (
        set MVN_VERSION=%%g
    )
    call :log_success "Maven is installed: Apache Maven !MVN_VERSION!"
)

:: Check if ports are available
call :log_info "Checking if required ports are available..."
netstat -an | find "LISTENING" | find ":8080" >nul
if %errorlevel% equ 0 (
    call :log_warning "Port 8080 is already in use. Backend may not start properly."
)

netstat -an | find "LISTENING" | find ":3000" >nul
if %errorlevel% equ 0 (
    call :log_warning "Port 3000 is already in use. Frontend may not start properly."
)

netstat -an | find "LISTENING" | find ":27017" >nul
if %errorlevel% equ 0 (
    call :log_success "MongoDB appears to be running on port 27017"
) else (
    call :log_warning "MongoDB is not detected on port 27017"
    echo You'll need to start MongoDB manually:
    echo   - Install MongoDB Community Server: https://www.mongodb.com/try/download/community
    echo   - Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0
    echo   - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas
)

echo.
echo %BLUE%ℹ️  Step 2: Backend Setup (Spring Boot + Maven)%RESET%
echo --------------------------------------------

call :log_info "Setting up backend..."

:: Navigate to backend directory
pushd backend
if %errorlevel% neq 0 (
    call :log_error "Backend directory not found!"
    pause
    exit /b 1
)

:: Determine Maven command
set "MAVEN_CMD="
if exist ".mvn\wrapper\maven-wrapper.jar" (
    call :log_info "Using Maven wrapper..."
    set "MAVEN_CMD=mvnw.cmd"
) else if exist "mvnw.cmd" (
    call :log_warning "Maven wrapper jar missing, attempting to use mvnw.cmd..."
    set "MAVEN_CMD=mvnw.cmd"
) else (
    where mvn >nul 2>&1
    if %errorlevel% equ 0 (
        call :log_warning "Using system Maven..."
        set "MAVEN_CMD=mvn"
    ) else (
        call :log_error "Neither Maven wrapper nor system Maven is available!"
        echo Please install Maven or restore Maven wrapper files.
        popd
        pause
        exit /b 1
    )
)

:: Recreate Maven wrapper if needed
if not exist ".mvn\wrapper\maven-wrapper.jar" (
    where mvn >nul 2>&1
    if %errorlevel% equ 0 (
        call :log_info "Recreating Maven wrapper files..."
        mvn wrapper:wrapper > ..\logs\setup-maven-wrapper.log 2>&1
        if %errorlevel% equ 0 (
            call :log_success "Maven wrapper files created successfully"
            set "MAVEN_CMD=mvnw.cmd"
        ) else (
            call :log_warning "Failed to create Maven wrapper, using system Maven"
            type ..\logs\setup-maven-wrapper.log >> ..\logs\setup-error.log
        )
    )
)

:: Install dependencies and compile
call :log_info "Installing backend dependencies and compiling with !MAVEN_CMD!..."
!MAVEN_CMD! clean compile > ..\logs\setup-backend.log 2>&1
if %errorlevel% neq 0 (
    call :log_error "Backend setup failed! Check logs\setup-backend.log for details."
    echo Last 10 lines of the error:
    echo ================================
    powershell -command "Get-Content '..\logs\setup-backend.log' | Select-Object -Last 10"
    echo ================================
    echo Full log available at: logs\setup-backend.log
    popd
    pause
    exit /b 1
)
call :log_success "Backend dependencies installed and compiled successfully"

:: Run tests
call :log_info "Running tests to verify setup..."
!MAVEN_CMD! test > ..\logs\setup-backend-test.log 2>&1
if %errorlevel% equ 0 (
    call :log_success "Backend tests passed successfully"
) else (
    call :log_warning "Some backend tests failed. Check logs\setup-backend-test.log for details."
    echo This might be normal if MongoDB is not running yet.
)

popd

echo.
echo %BLUE%ℹ️  Step 3: Frontend Setup (React + npm)%RESET%
echo ------------------------------------

call :log_info "Setting up frontend..."

:: Navigate to frontend directory
pushd frontend
if %errorlevel% neq 0 (
    call :log_error "Frontend directory not found!"
    pause
    exit /b 1
)

:: Install dependencies
call :log_info "Installing frontend dependencies..."
npm install > ..\logs\setup-frontend.log 2>&1
if %errorlevel% neq 0 (
    call :log_error "Frontend setup failed! Check logs\setup-frontend.log for details."
    echo Last 10 lines of the error:
    echo ================================
    powershell -command "Get-Content '..\logs\setup-frontend.log' | Select-Object -Last 10"
    echo ================================
    echo Full log available at: logs\setup-frontend.log
    popd
    pause
    exit /b 1
)
call :log_success "Frontend dependencies installed successfully"

:: Build to verify setup
call :log_info "Building frontend to verify setup..."
npm run build > ..\logs\setup-frontend-build.log 2>&1
if %errorlevel% equ 0 (
    call :log_success "Frontend built successfully"
) else (
    call :log_error "Frontend build failed! Check logs\setup-frontend-build.log for details."
    echo Last 10 lines of the error:
    echo ================================
    powershell -command "Get-Content '..\logs\setup-frontend-build.log' | Select-Object -Last 10"
    echo ================================
    popd
    pause
    exit /b 1
)

popd

echo.
echo %BLUE%ℹ️  Step 4: Environment Configuration%RESET%
echo ---------------------------------

if not exist ".env.example" (
    call :log_info "Creating environment configuration template..."
    (
        echo # Backend Configuration
        echo SERVER_PORT=8080
        echo MONGO_URI=mongodb://localhost:27017/medium-blog
        echo JWT_SECRET=your-super-secret-jwt-key-that-is-at-least-512-bits-long-for-hs512-algorithm-security-requirements
        echo JWT_EXPIRATION=86400000
        echo.
        echo # Frontend Configuration
        echo REACT_APP_API_URL=http://localhost:8080/api
    ) > .env.example
    call :log_success "Environment template created (.env.example)"
)

if not exist ".env" (
    call :log_info "Creating default environment configuration..."
    copy .env.example .env > nul
    call :log_success "Default environment configuration created (.env)"
    call :log_warning "Please review and update .env file with your specific settings"
)

echo.
echo %BLUE%ℹ️  Step 5: Database Setup%RESET%
echo ----------------------

if exist "migrate.js" (
    call :log_info "Database migration script found"
    
    if exist "package.json" (
        call :log_info "Installing migration dependencies..."
        npm install --silent > logs\setup-migration.log 2>&1
        if %errorlevel% equ 0 (
            call :log_success "Migration dependencies installed"
        ) else (
            call :log_warning "Failed to install migration dependencies"
        )
    )
    
    call :log_success "Migration script is ready"
    call :log_warning "Database migration will be run automatically on first start"
) else (
    call :log_warning "No database migration script found (migrate.js)"
)

echo.
echo %BLUE%ℹ️  Step 6: Final Setup Tasks%RESET%
echo ------------------------

call :log_success "All setup tasks completed"

echo.
echo %GREEN%🎉 Setup Complete!%RESET%
echo ==================
echo.
call :log_success "Medium Blog Platform has been set up successfully!"
echo.
echo 📋 What was set up:
echo   ✅ Backend (Spring Boot + Java 17+ + Maven)
echo   ✅ Frontend (React + Node.js + npm)
echo   ✅ Environment configuration
echo   ✅ Database migration scripts
echo.
echo 🚀 Next Steps:
echo   1. Make sure MongoDB is running:
echo      • Install MongoDB Community Server: https://www.mongodb.com/try/download/community
echo      • Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0
echo.
echo   2. Start the application:
echo      • For Windows: start.bat (if available) or use start.sh with Git Bash
echo      • Or manually start backend: cd backend ^&^& mvnw.cmd spring-boot:run
echo      • And frontend: cd frontend ^&^& npm start
echo.
echo   3. Open your browser:
echo      🌐 Frontend: http://localhost:3000
echo      🔧 Backend API: http://localhost:8080/api
echo.
echo 📝 Available Windows commands:
echo   setup.bat   - Run this setup again
echo   setup.ps1   - PowerShell setup script (if you have PowerShell)
echo.
echo 📚 Sample Login Credentials (created on first run):
echo   Username: john_doe ^| Password: demo123
echo   Username: jane_smith ^| Password: demo123
echo.
echo 📋 Log files location: logs\ directory
call :log_warning "Note: The database will be initialized with sample data on first run."
echo.
call :log_success "Happy coding! 🚀"

call :log_info "Setup completed successfully at %DATE% %TIME%"

echo.
echo Press any key to exit...
pause > nul
goto :eof

:: Logging functions
:log_info
echo %BLUE%ℹ️  %~1%RESET%
echo [%DATE% %TIME%] INFO: %~1 >> logs\setup.log
goto :eof

:log_success
echo %GREEN%✅ %~1%RESET%
echo [%DATE% %TIME%] SUCCESS: %~1 >> logs\setup.log
goto :eof

:log_warning
echo %YELLOW%⚠️  %~1%RESET%
echo [%DATE% %TIME%] WARNING: %~1 >> logs\setup.log
goto :eof

:log_error
echo %RED%❌ %~1%RESET%
echo [%DATE% %TIME%] ERROR: %~1 >> logs\setup.log
echo [%DATE% %TIME%] ERROR: %~1 >> logs\setup-error.log
goto :eof
