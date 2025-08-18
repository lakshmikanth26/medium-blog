#!/bin/bash

echo "🛑 Stopping Medium Blog Platform (Local Mode)..."

# Function to stop service by PID file
stop_service() {
    local service_name=$1
    local pid_file=$2
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "🛑 Stopping $service_name (PID: $pid)..."
            kill "$pid"
            sleep 2
            if kill -0 "$pid" 2>/dev/null; then
                echo "⚠️  $service_name didn't stop gracefully, force killing..."
                kill -9 "$pid"
            fi
            echo "✅ $service_name stopped"
        else
            echo "ℹ️  $service_name is not running"
        fi
        rm -f "$pid_file"
    else
        echo "ℹ️  No PID file found for $service_name"
    fi
}

# Stop backend
stop_service "Backend" "backend.pid"

# Stop frontend
stop_service "Frontend" "frontend.pid"

# Clean up log files (optional)
read -p "Do you want to remove log files? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing log files..."
    rm -f backend.log frontend.log
    echo "✅ Log files removed"
fi

echo ""
echo "✅ All services stopped successfully!"
echo ""
echo "📝 To start again: ./start.sh" 