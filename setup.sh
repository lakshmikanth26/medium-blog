#!/bin/bash

echo "🎯 Medium Blog Platform - First Time Setup"
echo "========================================="

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log_message "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log_message "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_message "WARNING" "$1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log_message "ERROR" "$1"
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Ensure logs directory exists
    mkdir -p logs
    
    # Write to main log file
    echo "[$timestamp] $level: $message" >> logs/setup.log
    
    # Write errors to separate error log
    if [ "$level" = "ERROR" ]; then
        echo "[$timestamp] ERROR: $message" >> logs/setup-error.log
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Java version
check_java_version() {
    if command_exists java; then
        local java_version=$(java -version 2>&1 | grep version | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$java_version" -ge 17 ] 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Function to check Node.js version
check_node_version() {
    if command_exists node; then
        local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -ge 16 ] 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Function to recreate Maven wrapper files
recreate_maven_wrapper() {
    if command_exists mvn; then
        print_status "Recreating Maven wrapper files..."
        if mvn wrapper:wrapper > ../setup-maven-wrapper.log 2>&1; then
            print_success "Maven wrapper files created successfully"
            rm -f ../setup-maven-wrapper.log
            return 0
        else
            print_warning "Failed to create Maven wrapper files, will use system Maven"
            return 1
        fi
    else
        return 1
    fi
}

echo ""
print_status "Step 1: Checking System Prerequisites"
echo "------------------------------------"

# Check Java
print_status "Checking Java installation..."
if check_java_version; then
    java_full_version=$(java -version 2>&1 | head -n 1)
    print_success "Java is installed: $java_full_version"
else
    print_error "Java 17+ is required but not found!"
    echo "Please install Java 17+ and try again:"
    echo "  - macOS: brew install openjdk@17"
    echo "  - Ubuntu: sudo apt install openjdk-17-jdk"
    echo "  - Windows: Download from https://adoptium.net/"
    exit 1
fi

# Check Node.js
print_status "Checking Node.js installation..."
if check_node_version; then
    node_full_version=$(node -v)
    print_success "Node.js is installed: $node_full_version"
else
    print_error "Node.js 16+ is required but not found!"
    echo "Please install Node.js 16+ and try again:"
    echo "  - Visit: https://nodejs.org/"
    echo "  - Or use nvm: nvm install --lts"
    exit 1
fi

# Check npm
print_status "Checking npm installation..."
if command_exists npm; then
    npm_version=$(npm -v)
    print_success "npm is installed: v$npm_version"
else
    print_error "npm is not installed!"
    echo "npm should come with Node.js. Please reinstall Node.js."
    exit 1
fi

# Check Maven (optional, will use wrapper)
print_status "Checking Maven installation..."
if command_exists mvn; then
    mvn_version=$(mvn -v | head -n 1)
    print_success "Maven is installed: $mvn_version"
else
    print_warning "Maven not found, will use Maven wrapper (mvnw)"
fi

# Check MongoDB
print_status "Checking MongoDB availability..."
if lsof -i :27017 > /dev/null 2>&1; then
    print_success "MongoDB is running on port 27017"
elif command_exists mongod; then
    print_warning "MongoDB is installed but not running"
    echo "MongoDB installation found. You can start it with:"
    echo "  - macOS (Homebrew): brew services start mongodb-community"
    echo "  - Manual: mongod --dbpath /usr/local/var/mongodb"
elif command_exists docker; then
    print_warning "MongoDB not found, but Docker is available"
    echo "You can run MongoDB with Docker:"
    echo "  docker run -d --name mongodb -p 27017:27017 mongo:6.0"
else
    print_warning "MongoDB not detected"
    echo "Please install MongoDB or use Docker:"
    echo "  - macOS: brew install mongodb-community"
    echo "  - Ubuntu: sudo apt install mongodb"
    echo "  - Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
fi

echo ""
print_status "Step 2: Backend Setup (Spring Boot + Maven)"
echo "--------------------------------------------"

cd backend || {
    print_error "Backend directory not found!"
    exit 1
}

# Determine which Maven command to use
MAVEN_CMD=""
if [ -d ".mvn/wrapper" ] && [ -f ".mvn/wrapper/maven-wrapper.jar" ]; then
    print_status "Using Maven wrapper..."
    chmod +x mvnw
    MAVEN_CMD="./mvnw"
elif command_exists mvn; then
    print_warning "Maven wrapper files missing, attempting to recreate them..."
    if recreate_maven_wrapper; then
        chmod +x mvnw
        MAVEN_CMD="./mvnw"
    else
        print_warning "Using system Maven as fallback..."
        MAVEN_CMD="mvn"
    fi
else
    print_error "Neither Maven wrapper nor system Maven is available!"
    echo "Please install Maven or restore Maven wrapper files."
    exit 1
fi

print_status "Installing backend dependencies and compiling with $MAVEN_CMD..."
if $MAVEN_CMD clean compile > ../logs/setup-backend.log 2>&1; then
    print_success "Backend dependencies installed and compiled successfully"
else
    print_error "Backend setup failed! Check logs/setup-backend.log for details."
    echo ""
    echo "Last 10 lines of the error:"
    echo "================================"
    tail -n 10 ../logs/setup-backend.log
    echo "================================"
    echo "Full log available at: logs/setup-backend.log"
    echo ""
    # Copy error to main error log
    cat ../logs/setup-backend.log >> ../logs/setup-error.log
    exit 1
fi

print_status "Running tests to ensure everything is working..."
if $MAVEN_CMD test > ../logs/setup-backend-test.log 2>&1; then
    print_success "Backend tests passed successfully"
else
    print_warning "Some backend tests failed. Check logs/setup-backend-test.log for details."
    echo "This might be normal if MongoDB is not running yet."
    echo "Last few lines of test output:"
    tail -n 5 ../logs/setup-backend-test.log
fi

cd ..

echo ""
print_status "Step 3: Frontend Setup (React + npm)"
echo "------------------------------------"

cd frontend || {
    print_error "Frontend directory not found!"
    exit 1
}

print_status "Installing frontend dependencies..."
if npm install > ../logs/setup-frontend.log 2>&1; then
    print_success "Frontend dependencies installed successfully"
else
    print_error "Frontend setup failed! Check logs/setup-frontend.log for details."
    echo ""
    echo "Last 10 lines of the error:"
    echo "================================"
    tail -n 10 ../logs/setup-frontend.log
    echo "================================"
    echo "Full log available at: logs/setup-frontend.log"
    echo ""
    # Copy error to main error log
    cat ../logs/setup-frontend.log >> ../logs/setup-error.log
    exit 1
fi

print_status "Building frontend to verify setup..."
if npm run build > ../logs/setup-frontend-build.log 2>&1; then
    print_success "Frontend built successfully"
else
    print_error "Frontend build failed! Check logs/setup-frontend-build.log for details."
    echo ""
    echo "Last 10 lines of the error:"
    echo "================================"
    tail -n 10 ../logs/setup-frontend-build.log
    echo "================================"
    echo "Full log available at: logs/setup-frontend-build.log"
    echo ""
    # Copy error to main error log
    cat ../logs/setup-frontend-build.log >> ../logs/setup-error.log
    exit 1
fi

cd ..

echo ""
print_status "Step 4: Environment Configuration"
echo "---------------------------------"

# Create environment configuration template if it doesn't exist
if [ ! -f ".env.example" ]; then
    print_status "Creating environment configuration template..."
    cat > .env.example << 'EOF'
# Backend Configuration
SERVER_PORT=8080
MONGO_URI=mongodb://localhost:27017/medium-blog
JWT_SECRET=your-super-secret-jwt-key-that-is-at-least-512-bits-long-for-hs512-algorithm-security-requirements
JWT_EXPIRATION=86400000

# Frontend Configuration (if needed)
REACT_APP_API_URL=http://localhost:8080/api
EOF
    print_success "Environment template created (.env.example)"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    print_status "Creating default environment configuration..."
    cp .env.example .env
    print_success "Default environment configuration created (.env)"
    print_warning "Please review and update .env file with your specific settings"
fi

echo ""
print_status "Step 5: Database Setup"
echo "----------------------"

# Check if migration script exists
if [ -f "migrate.js" ]; then
    print_status "Database migration script found"
    
    # Install migration dependencies if package.json exists at root
    if [ -f "package.json" ]; then
        print_status "Installing migration dependencies..."
        if npm install --silent > logs/setup-migration.log 2>&1; then
            print_success "Migration dependencies installed"
        else
            print_warning "Failed to install migration dependencies - check logs/setup-migration.log"
        fi
    fi
    
    # Make migration script executable
    chmod +x migrate.js
    print_success "Migration script is ready"
    
    print_warning "Database migration will be run automatically on first start"
else
    print_warning "No database migration script found (migrate.js)"
fi

echo ""
print_status "Step 6: Final Setup Tasks"
echo "------------------------"

# Make scripts executable
chmod +x start.sh stop.sh setup.sh

# Ensure logs directory exists
mkdir -p logs

print_success "All scripts are now executable"
print_success "Logs directory created"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
print_success "Medium Blog Platform has been set up successfully!"
echo ""
echo "📋 What was set up:"
echo "  ✅ Backend (Spring Boot + Java 17 + Maven)"
echo "  ✅ Frontend (React + Node.js + npm)"
echo "  ✅ Environment configuration"
echo "  ✅ Database migration scripts"
echo "  ✅ Executable scripts"
echo ""
echo "🚀 Next Steps:"
echo "  1. Make sure MongoDB is running:"
echo "     • brew services start mongodb-community (macOS)"
echo "     • docker run -d --name mongodb -p 27017:27017 mongo:6.0 (Docker)"
echo ""
echo "  2. Start the application:"
echo "     ./start.sh"
echo ""
echo "  3. Open your browser:"
echo "     🌐 Frontend: http://localhost:3000"
echo "     🔧 Backend API: http://localhost:8080/api"
echo ""
echo "📝 Available commands:"
echo "  Unix/Linux/macOS:"
echo "    ./start.sh  - Start both backend and frontend"
echo "    ./stop.sh   - Stop all services"
echo "    ./setup.sh  - Run this setup again (if needed)"
echo ""
echo "  Windows:"
echo "    setup.bat   - Windows batch setup script"
echo "    setup.ps1   - PowerShell setup script"
echo ""
echo "📚 Sample Login Credentials (created on first run):"
echo "  Username: john_doe | Password: demo123"
echo "  Username: jane_smith | Password: demo123"
echo ""
echo "📋 Log files location: logs/ directory"
echo "  - setup.log           : Complete setup log"
echo "  - setup-error.log     : Error messages only"
echo "  - setup-backend.log   : Backend compilation log"
echo "  - setup-frontend.log  : Frontend installation log"
echo ""
print_warning "Note: The database will be initialized with sample data on first run."
echo ""
print_success "Happy coding! 🚀"
echo ""
log_message "INFO" "Setup completed successfully at $(date)"
