# Medium Blog Platform - Unified Setup and Start Script
# This single script handles both initial setup and starting the application

param(
    [switch]$Setup,
    [switch]$Start,
    [switch]$Backend,
    [switch]$Frontend,
    [switch]$Help
)

# Set error handling
$ErrorActionPreference = "Continue"

function Write-Status {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Type) {
        "SUCCESS" { Write-Host "[$timestamp] SUCCESS: $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] WARNING: $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red }
        "INFO" { Write-Host "[$timestamp] INFO: $Message" -ForegroundColor Cyan }
        default { Write-Host "[$timestamp] $Message" -ForegroundColor White }
    }
}

function Test-Command {
    param([string]$Command)
    try {
        return (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
    }
    catch {
        return $false
    }
}

function Test-Port {
    param([int]$Port)
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $Port -WarningAction SilentlyContinue
        return $connection.TcpTestSucceeded
    }
    catch {
        return $false
    }
}

function Show-Help {
    Write-Host "Medium Blog Platform - Unified Setup and Start Script" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Cyan
    Write-Host "    .\medium-blog.ps1 [COMMAND] [OPTIONS]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "COMMANDS:" -ForegroundColor Cyan
    Write-Host "    -Setup      Run initial setup (install dependencies, compile)" -ForegroundColor Cyan
    Write-Host "    -Start      Start both backend and frontend" -ForegroundColor Cyan
    Write-Host "    -Backend    Start only the backend" -ForegroundColor Cyan
    Write-Host "    -Frontend   Start only the frontend" -ForegroundColor Cyan
    Write-Host "    -Help       Show this help message" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Cyan
    Write-Host "    .\medium-blog.ps1 -Setup     # First time setup" -ForegroundColor Cyan
    Write-Host "    .\medium-blog.ps1 -Start     # Start both services" -ForegroundColor Cyan
    Write-Host "    .\medium-blog.ps1 -Backend   # Start backend only" -ForegroundColor Cyan
    Write-Host "    .\medium-blog.ps1 -Frontend  # Start frontend only" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "REQUIREMENTS:" -ForegroundColor Cyan
    Write-Host "    - PowerShell 5.1 or higher" -ForegroundColor Cyan
    Write-Host "    - Java 17 or higher" -ForegroundColor Cyan
    Write-Host "    - Node.js 16 or higher" -ForegroundColor Cyan
    Write-Host "    - MongoDB (local or Docker)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "QUICK START:" -ForegroundColor Cyan
    Write-Host "    1. .\medium-blog.ps1 -Setup   # First time only" -ForegroundColor Cyan
    Write-Host "    2. .\medium-blog.ps1 -Start   # Start the application" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ACCESS URLs:" -ForegroundColor Cyan
    Write-Host "    Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "    Backend API: http://localhost:8080/api" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Sample Login Credentials:" -ForegroundColor Cyan
    Write-Host "    Username: john_doe | Password: demo123" -ForegroundColor Cyan
    Write-Host "    Username: jane_smith | Password: demo123" -ForegroundColor Cyan
}

function Invoke-Setup {
    Write-Host "Medium Blog Platform - Setup" -ForegroundColor Blue
    Write-Host "============================" -ForegroundColor Blue
    Write-Host ""

    # Check if running in correct directory
    if (!(Test-Path "backend") -or !(Test-Path "frontend")) {
        Write-Status "Please run this script from the project root directory!" "ERROR"
        Write-Status "Current directory: $(Get-Location)" "ERROR"
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Status "Starting setup process..."

    # Check Java
    Write-Status "Checking Java installation..."
    if (Test-Command "java") {
        try {
            $javaOutput = & java -version 2>&1
            if ($javaOutput -match '"(\d+\.\d+\.\d+[^"]*)"') {
                $javaVersion = $matches[1]
                $javaMajor = $javaVersion.Split('.')[0]
                if ([int]$javaMajor -ge 17) {
                    Write-Status "Java is installed: $javaVersion" "SUCCESS"
                } else {
                    Write-Status "Java 17+ required, but found Java $javaVersion" "ERROR"
                    Read-Host "Press Enter to exit"
                    exit 1
                }
            } else {
                Write-Status "Could not determine Java version" "WARNING"
            }
        }
        catch {
            Write-Status "Could not determine Java version" "WARNING"
        }
    } else {
        Write-Status "Java is not installed or not in PATH!" "ERROR"
        Write-Host "Please install Java 17+ from: https://adoptium.net/"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check Node.js
    Write-Status "Checking Node.js installation..."
    if (Test-Command "node") {
        try {
            $nodeVersion = & node --version
            $nodeMajor = $nodeVersion.TrimStart('v').Split('.')[0]
            if ([int]$nodeMajor -ge 16) {
                Write-Status "Node.js is installed: $nodeVersion" "SUCCESS"
            } else {
                Write-Status "Node.js 16+ required, but found $nodeVersion" "ERROR"
                exit 1
            }
        }
        catch {
            Write-Status "Could not determine Node.js version" "WARNING"
        }
    } else {
        Write-Status "Node.js is not installed or not in PATH!" "ERROR"
        Write-Host "Please install Node.js 16+ from: https://nodejs.org/"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check npm
    Write-Status "Checking npm installation..."
    if (Test-Command "npm") {
        try {
            $npmVersion = & npm --version
            Write-Status "npm is installed: v$npmVersion" "SUCCESS"
        }
        catch {
            Write-Status "Could not determine npm version" "WARNING"
        }
    } else {
        Write-Status "npm is not installed!" "ERROR"
        Write-Host "npm should come with Node.js. Please reinstall Node.js."
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check Maven
    Write-Status "Checking Maven installation..."
    if (Test-Command "mvn") {
        try {
            $mvnOutput = & mvn --version 2>&1 | Select-Object -First 1
            Write-Status "Maven is installed: $mvnOutput" "SUCCESS"
        }
        catch {
            Write-Status "Maven found but could not determine version" "WARNING"
        }
    } else {
        Write-Status "Maven not found, will use Maven wrapper (mvnw.cmd)" "WARNING"
    }

    # Check ports
    Write-Status "Checking if required ports are available..."
    if (Test-Port 8080) {
        Write-Status "Port 8080 is already in use. Backend may not start properly." "WARNING"
    } else {
        Write-Status "Port 8080 is available" "SUCCESS"
    }

    if (Test-Port 3000) {
        Write-Status "Port 3000 is already in use. Frontend may not start properly." "WARNING"
    } else {
        Write-Status "Port 3000 is available" "SUCCESS"
    }

    if (Test-Port 27017) {
        Write-Status "MongoDB appears to be running on port 27017" "SUCCESS"
    } else {
        Write-Status "MongoDB is not detected on port 27017" "WARNING"
        Write-Host "You'll need to start MongoDB manually:"
        Write-Host "  - Install MongoDB Community Server: https://www.mongodb.com/try/download/community"
        Write-Host "  - Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
        Write-Host "  - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas"
    }

    Write-Host ""
    Write-Status "Setting up backend..."

    # Navigate to backend directory
    try {
        Push-Location "backend"
    }
    catch {
        Write-Status "Backend directory not found!" "ERROR"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Determine Maven command
    $mavenCmd = ""
    if (Test-Command "mvn") {
        Write-Status "Using system Maven..."
        $mavenCmd = "mvn"
    } elseif (Test-Path "mvnw.cmd") {
        Write-Status "Using Maven wrapper..."
        $mavenCmd = ".\mvnw.cmd"
    } else {
        Write-Status "Neither Maven wrapper nor system Maven is available!" "ERROR"
        Write-Host "Please install Maven or restore Maven wrapper files."
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Install dependencies and compile
    Write-Status "Installing backend dependencies and compiling with $mavenCmd..."
    try {
        & $mavenCmd clean compile
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Backend setup failed!" "ERROR"
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Status "Backend dependencies installed and compiled successfully" "SUCCESS"
    }
    catch {
        Write-Status "Error during backend compilation: $($_.Exception.Message)" "ERROR"
        Pop-Location
        exit 1
    }

    Pop-Location

    Write-Status "Setting up frontend..."

    # Navigate to frontend directory
    try {
        Push-Location "frontend"
    }
    catch {
        Write-Status "Frontend directory not found!" "ERROR"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Install dependencies
    Write-Status "Installing frontend dependencies..."
    try {
        & npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Frontend setup failed!" "ERROR"
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Status "Frontend dependencies installed successfully" "SUCCESS"
    }
    catch {
        Write-Status "Error during frontend installation: $($_.Exception.Message)" "ERROR"
        Pop-Location
        exit 1
    }

    # Build to verify setup
    Write-Status "Building frontend to verify setup..."
    try {
        & npm run build
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Frontend built successfully" "SUCCESS"
        } else {
            Write-Status "Frontend build failed!" "ERROR"
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    catch {
        Write-Status "Error during frontend build: $($_.Exception.Message)" "ERROR"
        Pop-Location
        exit 1
    }

    Pop-Location

    Write-Host ""
    Write-Status "Setup Complete!" "SUCCESS"
    Write-Host ""
    Write-Host "What was set up:"
    Write-Host "  - Backend (Spring Boot + Java 17+ + Maven)"
    Write-Host "  - Frontend (React + Node.js + npm)"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  .\medium-blog.ps1 -Start     # Start both services"
    Write-Host "  .\medium-blog.ps1 -Backend   # Start backend only"
    Write-Host "  .\medium-blog.ps1 -Frontend  # Start frontend only"
    Write-Host ""
}

function Start-Backend {
    Write-Host "Starting Medium Blog Backend..." -ForegroundColor Blue
    Write-Host "=================================" -ForegroundColor Blue
    Write-Host ""

    # Check if MongoDB is running
    Write-Status "Checking MongoDB connection..."
    if (Test-Port 27017) {
        Write-Status "MongoDB is running on port 27017" "SUCCESS"
    } else {
        Write-Status "MongoDB is not running on port 27017" "ERROR"
        Write-Host "Please start MongoDB first:"
        Write-Host "  - Open MongoDB Compass"
        Write-Host "  - Or run: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
        Read-Host "Press Enter to continue anyway, or Ctrl+C to cancel"
    }

    # Navigate to backend directory
    try {
        Push-Location "backend"
    }
    catch {
        Write-Status "Backend directory not found!" "ERROR"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check if Maven is available
    if (Test-Command "mvn") {
        Write-Status "Using system Maven..."
        $mavenCmd = "mvn"
    } elseif (Test-Path "mvnw.cmd") {
        Write-Status "Using Maven wrapper..."
        $mavenCmd = ".\mvnw.cmd"
    } else {
        Write-Status "Neither Maven nor Maven wrapper found!" "ERROR"
        Write-Host "Please install Maven or restore Maven wrapper files."
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Status "Starting Spring Boot application..."
    Write-Host "Backend will be available at: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "API endpoints: http://localhost:8080/api" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the backend" -ForegroundColor Yellow
    Write-Host ""

    # Start the backend
    try {
        & $mavenCmd spring-boot:run
    }
    catch {
        Write-Status "Error starting backend: $($_.Exception.Message)" "ERROR"
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }
    finally {
        Pop-Location
    }
}

function Start-Frontend {
    Write-Host "Starting Medium Blog Frontend..." -ForegroundColor Blue
    Write-Host "==================================" -ForegroundColor Blue
    Write-Host ""
    
    Write-Status "Current working directory: $(Get-Location)"
    Write-Status "Checking if frontend directory exists: $(Test-Path 'frontend')"

    # Navigate to frontend directory
    try {
        Push-Location "frontend"
        Write-Status "Current directory after navigation: $(Get-Location)"
    }
    catch {
        Write-Status "Frontend directory not found!" "ERROR"
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check if node_modules exists
    if (!(Test-Path "node_modules")) {
        Write-Status "Installing frontend dependencies..."
        Write-Status "Running from directory: $(Get-Location)"
        try {
            $npmCmd = "npm"
            & $npmCmd install
            if ($LASTEXITCODE -ne 0) {
                Write-Status "Failed to install frontend dependencies!" "ERROR"
                Pop-Location
                Read-Host "Press Enter to exit"
                exit 1
            }
            Write-Status "Frontend dependencies installed successfully" "SUCCESS"
        }
        catch {
            Write-Status "Error installing dependencies: $($_.Exception.Message)" "ERROR"
            Pop-Location
            Read-Host "Press Enter to exit"
            exit 1
        }
    }

    Write-Status "Starting React development server..."
    Write-Host "Frontend will be available at: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the frontend" -ForegroundColor Yellow
    Write-Host ""

    # Start the frontend
    try {
        $npmCmd = "npm"
        & $npmCmd start
    }
    catch {
        Write-Status "Error starting frontend: $($_.Exception.Message)" "ERROR"
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }
    finally {
        Pop-Location
    }
}

function Start-All {
    Write-Host "Starting Medium Blog Platform (All Services)..." -ForegroundColor Blue
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host ""

    # Check if MongoDB is running
    Write-Status "Checking MongoDB connection..."
    if (Test-Port 27017) {
        Write-Status "MongoDB is running on port 27017" "SUCCESS"
    } else {
        Write-Status "MongoDB is not running on port 27017" "ERROR"
        Write-Host "Please start MongoDB first:"
        Write-Host "  - Open MongoDB Compass"
        Write-Host "  - Or run: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
        Read-Host "Press Enter to continue anyway, or Ctrl+C to cancel"
    }

    Write-Status "Starting Backend..."

    # Start backend in background
    $backendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Push-Location "backend"
        
        if (Get-Command "mvn" -ErrorAction SilentlyContinue) {
            & mvn spring-boot:run
        } elseif (Test-Path "mvnw.cmd") {
            & .\mvnw.cmd spring-boot:run
        } else {
            Write-Host "ERROR: Neither Maven nor Maven wrapper found!" -ForegroundColor Red
            exit 1
        }
        
        Pop-Location
    }

    Write-Status "Waiting for backend to start..."
    $backendStarted = $false
    for ($i = 1; $i -le 30; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/api/posts" -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                Write-Status "Backend is running on http://localhost:8080" "SUCCESS"
                $backendStarted = $true
                break
            }
        }
        catch {
            # Backend not ready yet
        }
        Start-Sleep -Seconds 2
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }

    if (-not $backendStarted) {
        Write-Host ""
        Write-Status "Backend failed to start within 60 seconds" "ERROR"
        Write-Host "Check backend logs for details"
        Stop-Job $backendJob
        Remove-Job $backendJob
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host ""
    Write-Status "Starting Frontend..."

    # Start frontend in background
    $frontendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Push-Location "frontend"
        
        if (!(Test-Path "node_modules")) {
            & npm install
        }
        
        & npm start
        
        Pop-Location
    }

    Write-Status "Waiting for frontend to start..."
    $frontendStarted = $false
    for ($i = 1; $i -le 30; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                Write-Status "Frontend is running on http://localhost:3000" "SUCCESS"
                $frontendStarted = $true
                break
            }
        }
        catch {
            # Frontend not ready yet
        }
        Start-Sleep -Seconds 2
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }

    if (-not $frontendStarted) {
        Write-Host ""
        Write-Status "Frontend failed to start within 60 seconds" "ERROR"
        Write-Host "Check frontend logs for details"
    }

    Write-Host ""
    Write-Status "Medium Blog Platform is running!" "SUCCESS"
    Write-Host "=================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Backend API: http://localhost:8080/api" -ForegroundColor Cyan
    Write-Host "Database: MongoDB on localhost:27017" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Sample Login Credentials:" -ForegroundColor Yellow
    Write-Host "   Username: john_doe | Password: demo123" -ForegroundColor White
    Write-Host "   Username: jane_smith | Password: demo123" -ForegroundColor White
    Write-Host ""
    Write-Host "To stop all services: Press Ctrl+C" -ForegroundColor Red
    Write-Host ""

    # Function to cleanup on exit
    function Cleanup {
        Write-Host ""
        Write-Status "Stopping services..."
        
        if ($backendJob) {
            Write-Status "Stopping backend..."
            Stop-Job $backendJob
            Remove-Job $backendJob
        }
        
        if ($frontendJob) {
            Write-Status "Stopping frontend..."
            Stop-Job $frontendJob
            Remove-Job $frontendJob
        }
        
        Write-Status "Services stopped." "SUCCESS"
        exit 0
    }

    # Set up signal handlers
    $null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Cleanup }

    # Keep script running
    Write-Host "Services are running. Press Ctrl+C to stop all services..." -ForegroundColor Green
    while ($true) {
        Start-Sleep -Seconds 1
    }
}

# Main script logic
if ($Help) {
    Show-Help
    exit 0
}

if ($Setup) {
    Invoke-Setup
    exit 0
}

if ($Backend) {
    Start-Backend
    exit 0
}

if ($Frontend) {
    Write-Host "Calling Start-Frontend function..." -ForegroundColor Yellow
    Start-Frontend
    exit 0
}

if ($Start) {
    Start-All
    exit 0
}

# If no parameters provided, show help
Show-Help
    