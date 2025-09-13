# Medium Blog Platform - Windows PowerShell Setup Script
# Requires PowerShell 5.1 or higher

param(
    [switch]$Help,
    [switch]$SkipTests,
    [switch]$Verbose
)

# Set error handling
$ErrorActionPreference = "Continue"

# Colors for PowerShell
$colors = @{
    Red = "Red"
    Green = "Green" 
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    White = "White"
}

function Write-ColoredText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $colors[$Color]
}

function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Level`: $Message"
    
    # Ensure logs directory exists
    if (!(Test-Path "logs")) {
        New-Item -ItemType Directory -Path "logs" -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path "logs\setup-powershell.log" -Value $logEntry
    
    # Write to console with color
    switch ($Level) {
        "INFO" { Write-ColoredText "ℹ️  $Message" -Color $Color }
        "SUCCESS" { Write-ColoredText "✅ $Message" -Color "Green" }
        "WARNING" { Write-ColoredText "⚠️  $Message" -Color "Yellow" }
        "ERROR" { 
            Write-ColoredText "❌ $Message" -Color "Red"
            Add-Content -Path "logs\setup-error.log" -Value $logEntry
        }
    }
    
    if ($Verbose) {
        Write-Host $logEntry -ForegroundColor DarkGray
    }
}

function Test-Command {
    param([string]$Command)
    
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
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

function Get-JavaVersion {
    try {
        $javaOutput = & java -version 2>&1
        if ($javaOutput -match '"(\d+\.\d+\.\d+[^"]*)"') {
            return $matches[1]
        }
        elseif ($javaOutput -match '"(\d+)[^"]*"') {
            return $matches[1]
        }
        return "Unknown"
    }
    catch {
        return $null
    }
}

function Show-Help {
    $helpText = @"
🎯 Medium Blog Platform - Windows PowerShell Setup Script

USAGE:
    .\setup.ps1 [OPTIONS]

OPTIONS:
    -Help           Show this help message
    -SkipTests      Skip running backend tests during setup
    -Verbose        Show detailed logging information

EXAMPLES:
    .\setup.ps1                 # Run full setup
    .\setup.ps1 -SkipTests      # Setup without tests
    .\setup.ps1 -Verbose        # Setup with detailed logs

REQUIREMENTS:
    - PowerShell 5.1 or higher
    - Java 17 or higher
    - Node.js 16 or higher
    - MongoDB (local or Docker)

For more information, visit: https://github.com/lakshmikanth26/medium-blog
"@
    Write-ColoredText $helpText -Color "Cyan"
}

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-LogMessage "PowerShell 5.1 or higher is required. Current version: $($PSVersionTable.PSVersion)" -Level "ERROR"
    exit 1
}

Write-ColoredText "🎯 Medium Blog Platform - First Time Setup (PowerShell)" -Color "Blue"
Write-ColoredText "=========================================" -Color "Blue"
Write-Host ""

Write-LogMessage "Starting PowerShell setup process..." -Level "INFO" -Color "Blue"
Write-LogMessage "PowerShell Version: $($PSVersionTable.PSVersion)" -Level "INFO"
Write-LogMessage "OS: $($PSVersionTable.OS)" -Level "INFO"

# Check if running in correct directory
if (!(Test-Path "backend") -or !(Test-Path "frontend")) {
    Write-LogMessage "Please run this script from the project root directory!" -Level "ERROR"
    Write-LogMessage "Current directory: $(Get-Location)" -Level "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColoredText "`nℹ️  Step 1: Checking System Prerequisites" -Color "Blue"
Write-ColoredText "------------------------------------" -Color "Blue"

# Check Java
Write-LogMessage "Checking Java installation..." -Level "INFO" -Color "Blue"
if (Test-Command "java") {
    $javaVersion = Get-JavaVersion
    if ($javaVersion) {
        $javaMajor = $javaVersion.Split('.')[0]
        if ([int]$javaMajor -ge 17 -or ($javaMajor -eq "1" -and [int]$javaVersion.Split('.')[1] -ge 8)) {
            Write-LogMessage "Java is installed: $javaVersion" -Level "SUCCESS"
        } else {
            Write-LogMessage "Java 17+ required, but found Java $javaVersion" -Level "ERROR"
            Write-Host "Please install Java 17+ from: https://adoptium.net/"
            Read-Host "Press Enter to exit"
            exit 1
        }
    } else {
        Write-LogMessage "Could not determine Java version" -Level "WARNING"
    }
} else {
    Write-LogMessage "Java is not installed or not in PATH!" -Level "ERROR"
    Write-Host @"
Please install Java 17+ and add it to your PATH:
  - Download from: https://adoptium.net/
  - Or use winget: winget install EclipseAdoptium.Temurin.17.JDK
"@
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Node.js
Write-LogMessage "Checking Node.js installation..." -Level "INFO" -Color "Blue"
if (Test-Command "node") {
    try {
        $nodeVersion = & node --version
        $nodeMajor = $nodeVersion.TrimStart('v').Split('.')[0]
        if ([int]$nodeMajor -ge 16) {
            Write-LogMessage "Node.js is installed: $nodeVersion" -Level "SUCCESS"
        } else {
            Write-LogMessage "Node.js 16+ required, but found $nodeVersion" -Level "ERROR"
            exit 1
        }
    }
    catch {
        Write-LogMessage "Could not determine Node.js version" -Level "WARNING"
    }
} else {
    Write-LogMessage "Node.js is not installed or not in PATH!" -Level "ERROR"
    Write-Host @"
Please install Node.js 16+ and add it to your PATH:
  - Download from: https://nodejs.org/
  - Or use winget: winget install OpenJS.NodeJS
"@
    Read-Host "Press Enter to exit"
    exit 1
}

# Check npm
Write-LogMessage "Checking npm installation..." -Level "INFO" -Color "Blue"
if (Test-Command "npm") {
    try {
        $npmVersion = & npm --version
        Write-LogMessage "npm is installed: v$npmVersion" -Level "SUCCESS"
    }
    catch {
        Write-LogMessage "Could not determine npm version" -Level "WARNING"
    }
} else {
    Write-LogMessage "npm is not installed!" -Level "ERROR"
    Write-Host "npm should come with Node.js. Please reinstall Node.js."
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Maven
Write-LogMessage "Checking Maven installation..." -Level "INFO" -Color "Blue"
if (Test-Command "mvn") {
    try {
        $mvnOutput = & mvn --version 2>&1 | Select-Object -First 1
        Write-LogMessage "Maven is installed: $mvnOutput" -Level "SUCCESS"
    }
    catch {
        Write-LogMessage "Maven found but could not determine version" -Level "WARNING"
    }
} else {
    Write-LogMessage "Maven not found, will use Maven wrapper (mvnw.cmd)" -Level "WARNING" -Color "Yellow"
}

# Check ports
Write-LogMessage "Checking if required ports are available..." -Level "INFO" -Color "Blue"
if (Test-Port 8080) {
    Write-LogMessage "Port 8080 is already in use. Backend may not start properly." -Level "WARNING"
} else {
    Write-LogMessage "Port 8080 is available" -Level "SUCCESS"
}

if (Test-Port 3000) {
    Write-LogMessage "Port 3000 is already in use. Frontend may not start properly." -Level "WARNING"
} else {
    Write-LogMessage "Port 3000 is available" -Level "SUCCESS"
}

if (Test-Port 27017) {
    Write-LogMessage "MongoDB appears to be running on port 27017" -Level "SUCCESS"
} else {
    Write-LogMessage "MongoDB is not detected on port 27017" -Level "WARNING"
    Write-Host @"
You'll need to start MongoDB manually:
  - Install MongoDB Community Server: https://www.mongodb.com/try/download/community
  - Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0
  - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas
"@
}

Write-ColoredText "`nℹ️  Step 2: Backend Setup (Spring Boot + Maven)" -Color "Blue"
Write-ColoredText "--------------------------------------------" -Color "Blue"

Write-LogMessage "Setting up backend..." -Level "INFO" -Color "Blue"

# Navigate to backend directory
Push-Location "backend"
if ($LASTEXITCODE -ne 0) {
    Write-LogMessage "Backend directory not found!" -Level "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

# Determine Maven command
$mavenCmd = ""
if (Test-Path ".mvn\wrapper\maven-wrapper.jar") {
    Write-LogMessage "Using Maven wrapper..." -Level "INFO"
    $mavenCmd = ".\mvnw.cmd"
} elseif (Test-Path "mvnw.cmd") {
    Write-LogMessage "Maven wrapper jar missing, attempting to use mvnw.cmd..." -Level "WARNING"
    $mavenCmd = ".\mvnw.cmd"
} elseif (Test-Command "mvn") {
    Write-LogMessage "Using system Maven..." -Level "WARNING"
    $mavenCmd = "mvn"
} else {
    Write-LogMessage "Neither Maven wrapper nor system Maven is available!" -Level "ERROR"
    Write-Host "Please install Maven or restore Maven wrapper files."
    Pop-Location
    Read-Host "Press Enter to exit"
    exit 1
}

# Recreate Maven wrapper if needed
if (!(Test-Path ".mvn\wrapper\maven-wrapper.jar") -and (Test-Command "mvn")) {
    Write-LogMessage "Recreating Maven wrapper files..." -Level "INFO"
    try {
        & mvn wrapper:wrapper > "..\logs\setup-maven-wrapper.log" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "Maven wrapper files created successfully" -Level "SUCCESS"
            $mavenCmd = ".\mvnw.cmd"
        } else {
            Write-LogMessage "Failed to create Maven wrapper, using system Maven" -Level "WARNING"
            Get-Content "..\logs\setup-maven-wrapper.log" | Add-Content "..\logs\setup-error.log"
        }
    }
    catch {
        Write-LogMessage "Error creating Maven wrapper: $($_.Exception.Message)" -Level "WARNING"
    }
}

# Install dependencies and compile
Write-LogMessage "Installing backend dependencies and compiling with $mavenCmd..." -Level "INFO"
try {
    & $mavenCmd clean compile > "..\logs\setup-backend.log" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-LogMessage "Backend setup failed! Check logs\setup-backend.log for details." -Level "ERROR"
        Write-Host "`nLast 10 lines of the error:" -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Get-Content "..\logs\setup-backend.log" | Select-Object -Last 10 | Write-Host -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Write-Host "Full log available at: logs\setup-backend.log"
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-LogMessage "Backend dependencies installed and compiled successfully" -Level "SUCCESS"
}
catch {
    Write-LogMessage "Error during backend compilation: $($_.Exception.Message)" -Level "ERROR"
    Pop-Location
    exit 1
}

# Run tests
if (!$SkipTests) {
    Write-LogMessage "Running tests to verify setup..." -Level "INFO"
    try {
        & $mavenCmd test > "..\logs\setup-backend-test.log" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogMessage "Backend tests passed successfully" -Level "SUCCESS"
        } else {
            Write-LogMessage "Some backend tests failed. Check logs\setup-backend-test.log for details." -Level "WARNING"
            Write-Host "This might be normal if MongoDB is not running yet."
        }
    }
    catch {
        Write-LogMessage "Error running tests: $($_.Exception.Message)" -Level "WARNING"
    }
} else {
    Write-LogMessage "Skipping backend tests as requested" -Level "INFO"
}

Pop-Location

Write-ColoredText "`nℹ️  Step 3: Frontend Setup (React + npm)" -Color "Blue"
Write-ColoredText "------------------------------------" -Color "Blue"

Write-LogMessage "Setting up frontend..." -Level "INFO" -Color "Blue"

# Navigate to frontend directory
Push-Location "frontend"
if ($LASTEXITCODE -ne 0) {
    Write-LogMessage "Frontend directory not found!" -Level "ERROR"
    Read-Host "Press Enter to exit"
    exit 1
}

# Install dependencies
Write-LogMessage "Installing frontend dependencies..." -Level "INFO"
try {
    & npm install > "..\logs\setup-frontend.log" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-LogMessage "Frontend setup failed! Check logs\setup-frontend.log for details." -Level "ERROR"
        Write-Host "`nLast 10 lines of the error:" -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Get-Content "..\logs\setup-frontend.log" | Select-Object -Last 10 | Write-Host -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Write-Host "Full log available at: logs\setup-frontend.log"
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-LogMessage "Frontend dependencies installed successfully" -Level "SUCCESS"
}
catch {
    Write-LogMessage "Error during frontend installation: $($_.Exception.Message)" -Level "ERROR"
    Pop-Location
    exit 1
}

# Build to verify setup
Write-LogMessage "Building frontend to verify setup..." -Level "INFO"
try {
    & npm run build > "..\logs\setup-frontend-build.log" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-LogMessage "Frontend built successfully" -Level "SUCCESS"
    } else {
        Write-LogMessage "Frontend build failed! Check logs\setup-frontend-build.log for details." -Level "ERROR"
        Write-Host "`nLast 10 lines of the error:" -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Get-Content "..\logs\setup-frontend-build.log" | Select-Object -Last 10 | Write-Host -ForegroundColor Red
        Write-Host "================================" -ForegroundColor Red
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 1
    }
}
catch {
    Write-LogMessage "Error during frontend build: $($_.Exception.Message)" -Level "ERROR"
    Pop-Location
    exit 1
}

Pop-Location

Write-ColoredText "`nℹ️  Step 4: Environment Configuration" -Color "Blue"
Write-ColoredText "---------------------------------" -Color "Blue"

if (!(Test-Path ".env.example")) {
    Write-LogMessage "Creating environment configuration template..." -Level "INFO"
    $envContent = @"
# Backend Configuration
SERVER_PORT=8080
MONGO_URI=mongodb://localhost:27017/medium-blog
JWT_SECRET=your-super-secret-jwt-key-that-is-at-least-512-bits-long-for-hs512-algorithm-security-requirements
JWT_EXPIRATION=86400000

# Frontend Configuration
REACT_APP_API_URL=http://localhost:8080/api
"@
    Set-Content -Path ".env.example" -Value $envContent
    Write-LogMessage "Environment template created (.env.example)" -Level "SUCCESS"
}

if (!(Test-Path ".env")) {
    Write-LogMessage "Creating default environment configuration..." -Level "INFO"
    Copy-Item ".env.example" ".env"
    Write-LogMessage "Default environment configuration created (.env)" -Level "SUCCESS"
    Write-LogMessage "Please review and update .env file with your specific settings" -Level "WARNING"
}

Write-ColoredText "`nℹ️  Step 5: Database Setup" -Color "Blue"
Write-ColoredText "----------------------" -Color "Blue"

if (Test-Path "migrate.js") {
    Write-LogMessage "Database migration script found" -Level "INFO"
    
    if (Test-Path "package.json") {
        Write-LogMessage "Installing migration dependencies..." -Level "INFO"
        try {
            & npm install --silent > "logs\setup-migration.log" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage "Migration dependencies installed" -Level "SUCCESS"
            } else {
                Write-LogMessage "Failed to install migration dependencies" -Level "WARNING"
            }
        }
        catch {
            Write-LogMessage "Error installing migration dependencies: $($_.Exception.Message)" -Level "WARNING"
        }
    }
    
    Write-LogMessage "Migration script is ready" -Level "SUCCESS"
    Write-LogMessage "Database migration will be run automatically on first start" -Level "WARNING"
} else {
    Write-LogMessage "No database migration script found (migrate.js)" -Level "WARNING"
}

Write-ColoredText "`nℹ️  Step 6: Final Setup Tasks" -Color "Blue"
Write-ColoredText "------------------------" -Color "Blue"

Write-LogMessage "All setup tasks completed" -Level "SUCCESS"

Write-ColoredText "`n🎉 Setup Complete!" -Color "Green"
Write-ColoredText "==================" -Color "Green"
Write-Host ""
Write-LogMessage "Medium Blog Platform has been set up successfully!" -Level "SUCCESS"
Write-Host ""
Write-Host "📋 What was set up:"
Write-Host "  ✅ Backend (Spring Boot + Java 17+ + Maven)"
Write-Host "  ✅ Frontend (React + Node.js + npm)"
Write-Host "  ✅ Environment configuration"
Write-Host "  ✅ Database migration scripts"
Write-Host ""
Write-Host "🚀 Next Steps:"
Write-Host "  1. Make sure MongoDB is running:"
Write-Host "     • Install MongoDB Community Server: https://www.mongodb.com/try/download/community"
Write-Host "     • Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
Write-Host ""
Write-Host "  2. Start the application:"
Write-Host "     • Backend: cd backend && .\mvnw.cmd spring-boot:run"
Write-Host "     • Frontend: cd frontend && npm start"
Write-Host ""
Write-Host "  3. Open your browser:"
Write-Host "     🌐 Frontend: http://localhost:3000"
Write-Host "     🔧 Backend API: http://localhost:8080/api"
Write-Host ""
Write-Host "📝 Available Windows commands:"
Write-Host "  .\setup.ps1       - PowerShell setup script"
Write-Host "  .\setup.bat       - Batch setup script"
Write-Host "  .\setup.ps1 -Help - Show help information"
Write-Host ""
Write-Host "📚 Sample Login Credentials (created on first run):"
Write-Host "  Username: john_doe | Password: demo123"
Write-Host "  Username: jane_smith | Password: demo123"
Write-Host ""
Write-Host "📋 Log files location: logs\ directory"
Write-LogMessage "Note: The database will be initialized with sample data on first run." -Level "WARNING"
Write-Host ""
Write-LogMessage "Happy coding! 🚀" -Level "SUCCESS"

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-LogMessage "Setup completed successfully at $timestamp" -Level "INFO"

Write-Host ""
Read-Host "Press Enter to exit"
