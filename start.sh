#!/bin/bash

echo "🚀 Starting Medium Blog Platform (Local Mode)..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Java
if ! command_exists java; then
    echo "❌ Java is not installed. Please install Java 17+ and try again."
    exit 1
fi

# Check Node.js
if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ and try again."
    exit 1
fi

# Check npm
if ! command_exists npm; then
    echo "❌ npm is not installed. Please install npm and try again."
    exit 1
fi

# Check Maven (optional, will use Maven wrapper if not available)
if ! command_exists mvn; then
    echo "⚠️  Maven not found, will use Maven wrapper"
fi

echo "✅ Prerequisites check passed!"

# Function to check if this is first time setup
is_first_time_setup() {
    # Check if migration has been run by looking for the migrations collection
    # We'll create a simple marker file for this check
    [ ! -f ".migration_completed" ]
}

# Function to run database migration
run_migration() {
    echo "🗄️  Running database migration..."
    
    # Install migration dependencies if package.json exists
    if [ -f "package.json" ]; then
        echo "📦 Installing migration dependencies..."
        npm install --production --silent
    fi
    
    # Make migration script executable
    chmod +x migrate.js
    
    # Run migration
    if node migrate.js; then
        # Create marker file to indicate migration completed
        touch .migration_completed
        echo "✅ Database migration completed successfully!"
        return 0
    else
        echo "❌ Database migration failed!"
        return 1
    fi
}

# Function to check if MongoDB is running
check_mongodb() {
    if lsof -i :27017 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if MongoDB is running
echo "🗄️  Checking MongoDB..."
if check_mongodb; then
    echo "✅ MongoDB is already running on port 27017"
else
    echo "❌ MongoDB is not running on port 27017"
    echo "Please start MongoDB manually:"
    echo "  - If using MongoDB Compass: Open MongoDB Compass"
    echo "  - If using Homebrew: brew services start mongodb-community"
    echo "  - If using local MongoDB: mongod --dbpath /usr/local/var/mongodb"
    echo "  - If using Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0"
    echo ""
    read -p "Press Enter after starting MongoDB, or Ctrl+C to cancel..."
    
    # Check again
    if ! check_mongodb; then
        echo "❌ MongoDB is still not running. Please start MongoDB and try again."
        exit 1
    fi
fi

# Check if this is first time setup and run migration
if is_first_time_setup; then
    echo ""
    echo "🎯 First time setup detected!"
    echo "🗄️  Setting up database with initial data..."
    
    if ! run_migration; then
        echo "❌ Failed to run database migration"
        exit 1
    fi
    
    echo ""
else
    echo "🗄️  Database already initialized"
fi

# Function to start backend
start_backend() {
    echo "🔧 Starting Spring Boot Backend..."
    cd backend
    
    # Make Maven wrapper executable
    chmod +x mvnw
    
    # Start backend in background
    ./mvnw spring-boot:run > ../backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > ../backend.pid
    
    cd ..
    
    # Wait for backend to start
    echo "⏳ Waiting for backend to start..."
    for i in {1..30}; do
        if curl -s http://localhost:8080/api/posts > /dev/null 2>&1; then
            echo "✅ Backend is running on http://localhost:8080"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    echo "❌ Backend failed to start. Check backend.log for details."
    return 1
}

# Function to start frontend
start_frontend() {
    echo "🌐 Starting React Frontend..."
    cd frontend
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing frontend dependencies..."
        npm install
    fi
    
    # Start frontend in background
    npm start > ../frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > ../frontend.pid
    
    cd ..
    
    # Wait for frontend to start
    echo "⏳ Waiting for frontend to start..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            echo "✅ Frontend is running on http://localhost:3000"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    echo "❌ Frontend failed to start. Check frontend.log for details."
    return 1
}

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    
    # Stop backend
    if [ -f "backend.pid" ]; then
        BACKEND_PID=$(cat backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            echo "🛑 Stopping backend (PID: $BACKEND_PID)..."
            kill $BACKEND_PID
        fi
        rm -f backend.pid
    fi
    
    # Stop frontend
    if [ -f "frontend.pid" ]; then
        FRONTEND_PID=$(cat frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            echo "🛑 Stopping frontend (PID: $FRONTEND_PID)..."
            kill $FRONTEND_PID
        fi
        rm -f frontend.pid
    fi
    
    echo "✅ Services stopped."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start services
echo ""
echo "🚀 Starting services..."

# Start backend
if ! start_backend; then
    echo "❌ Failed to start backend"
    exit 1
fi

# Start frontend
if ! start_frontend; then
    echo "❌ Failed to start frontend"
    cleanup
    exit 1
fi

echo ""
echo "🎉 Medium Blog Platform is running successfully!"
echo ""
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:8080/api"
echo "🗄️  Database: MongoDB on localhost:27017"
echo ""
echo "👤 Sample Login Credentials:"
echo "   Username: john_doe | Password: demo123"
echo "   Username: jane_smith | Password: demo123"
echo ""
echo "📝 Logs:"
echo "  - Backend: tail -f backend.log"
echo "  - Frontend: tail -f frontend.log"
echo ""
echo "🛑 To stop all services: Press Ctrl+C or run ./stop.sh"
echo ""

# Keep script running
echo "Services are running. Press Ctrl+C to stop all services..."
while true; do
    sleep 1
done 