#!/usr/bin/env python3
"""
Medium Blog Platform - Unified Setup and Start Script
This single script handles both initial setup and starting the application
"""

import sys
import os
import subprocess
import argparse
import time
import socket
import signal
import shutil
from datetime import datetime
from pathlib import Path
import threading
import urllib.request
import urllib.error

# ANSI color codes
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    WHITE = '\033[97m'
    BLUE = '\033[94m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def write_status(message, msg_type="INFO"):
    """Print formatted status messages"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    colors = {
        "SUCCESS": Colors.GREEN,
        "WARNING": Colors.YELLOW,
        "ERROR": Colors.RED,
        "INFO": Colors.CYAN
    }
    color = colors.get(msg_type, Colors.WHITE)
    print(f"{color}[{timestamp}] {msg_type}: {message}{Colors.ENDC}")

def test_command(command):
    """Check if a command exists"""
    return shutil.which(command) is not None

def test_port(port):
    """Check if a port is in use"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex(('localhost', port))
    sock.close()
    return result == 0

def find_free_port(start_port, max_attempts=10):
    """Find a free port starting from start_port"""
    for port in range(start_port, start_port + max_attempts):
        if not test_port(port):
            return port
    return None

def show_help():
    """Display help information"""
    print(f"{Colors.CYAN}Medium Blog Platform - Unified Setup and Start Script{Colors.ENDC}")
    print(f"{Colors.CYAN}====================================================={Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}USAGE:{Colors.ENDC}")
    print(f"    {Colors.CYAN}python start.py [COMMAND]{Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}COMMANDS:{Colors.ENDC}")
    print(f"    {Colors.CYAN}setup      Run initial setup (install dependencies, compile){Colors.ENDC}")
    print(f"    {Colors.CYAN}start      Start both backend and frontend{Colors.ENDC}")
    print(f"    {Colors.CYAN}backend    Start only the backend{Colors.ENDC}")
    print(f"    {Colors.CYAN}frontend   Start only the frontend{Colors.ENDC}")
    print(f"    {Colors.CYAN}help       Show this help message{Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}EXAMPLES:{Colors.ENDC}")
    print(f"    {Colors.CYAN}python start.py setup     # First time setup{Colors.ENDC}")
    print(f"    {Colors.CYAN}python start.py start     # Start both services{Colors.ENDC}")
    print(f"    {Colors.CYAN}python start.py backend   # Start backend only{Colors.ENDC}")
    print(f"    {Colors.CYAN}python start.py frontend  # Start frontend only{Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}REQUIREMENTS:{Colors.ENDC}")
    print(f"    {Colors.CYAN}- Python 3.6 or higher{Colors.ENDC}")
    print(f"    {Colors.CYAN}- Java 17 or higher{Colors.ENDC}")
    print(f"    {Colors.CYAN}- Node.js 16 or higher{Colors.ENDC}")
    print(f"    {Colors.CYAN}- MongoDB (local or Docker){Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}QUICK START:{Colors.ENDC}")
    print(f"    {Colors.CYAN}1. python start.py setup   # First time only{Colors.ENDC}")
    print(f"    {Colors.CYAN}2. python start.py start   # Start the application{Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}ACCESS URLs:{Colors.ENDC}")
    print(f"    {Colors.CYAN}Frontend: http://localhost:<PORT> (auto-selected, typically 3002+){Colors.ENDC}")
    print(f"    {Colors.CYAN}Backend API: http://localhost:<PORT>/api (auto-selected, typically 8082+){Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}NOTE:{Colors.ENDC}")
    print(f"    {Colors.CYAN}Ports are automatically selected from available ports to avoid conflicts.{Colors.ENDC}")
    print(f"    {Colors.CYAN}The actual URLs will be displayed when you start the services.{Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}Sample Login Credentials:{Colors.ENDC}")
    print(f"    {Colors.CYAN}Username: john_doe | Password: demo123{Colors.ENDC}")
    print(f"    {Colors.CYAN}Username: jane_smith | Password: demo123{Colors.ENDC}")

def run_command(cmd, cwd=None, shell=False, show_output=False):
    """Run a command and return the result"""
    try:
        if isinstance(cmd, str) and not shell:
            cmd = cmd.split()
        
        if show_output:
            # Show real-time output
            result = subprocess.run(
                cmd,
                cwd=cwd,
                text=True,
                shell=shell
            )
            return result.returncode == 0, "", ""
        else:
            # Capture output
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                shell=shell
            )
            return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def invoke_setup():
    """Run initial setup"""
    print(f"{Colors.BLUE}Medium Blog Platform - Setup{Colors.ENDC}")
    print(f"{Colors.BLUE}============================{Colors.ENDC}")
    print("")

    # Check if running in correct directory
    if not os.path.exists("backend") or not os.path.exists("frontend"):
        write_status("Please run this script from the project root directory!", "ERROR")
        write_status(f"Current directory: {os.getcwd()}", "ERROR")
        sys.exit(1)

    write_status("Starting setup process...")

    # Check Java
    write_status("Checking Java installation...")
    if test_command("java"):
        success, stdout, stderr = run_command("java -version")
        version_output = stderr if stderr else stdout
        try:
            # Try to extract version from output
            if "version" in version_output:
                # Extract version number
                import re
                match = re.search(r'version "?(\d+)\.?(\d+)?\.?(\d+)?[^"]*"?', version_output)
                if match:
                    major = int(match.group(1))
                    if major >= 17:
                        write_status(f"Java is installed: {version_output.splitlines()[0]}", "SUCCESS")
                    else:
                        write_status(f"Java 17+ required, but found Java {major}", "ERROR")
                        sys.exit(1)
                else:
                    write_status("Could not determine Java version", "WARNING")
        except Exception:
            write_status("Could not determine Java version", "WARNING")
    else:
        write_status("Java is not installed or not in PATH!", "ERROR")
        print("Please install Java 17+ from: https://adoptium.net/")
        sys.exit(1)

    # Check Node.js
    write_status("Checking Node.js installation...")
    if test_command("node"):
        success, stdout, stderr = run_command("node --version")
        if success:
            version = stdout.strip()
            major = int(version.lstrip('v').split('.')[0])
            if major >= 16:
                write_status(f"Node.js is installed: {version}", "SUCCESS")
            else:
                write_status(f"Node.js 16+ required, but found {version}", "ERROR")
                sys.exit(1)
    else:
        write_status("Node.js is not installed or not in PATH!", "ERROR")
        print("Please install Node.js 16+ from: https://nodejs.org/")
        sys.exit(1)

    # Check npm
    write_status("Checking npm installation...")
    if test_command("npm"):
        success, stdout, stderr = run_command("npm --version")
        if success:
            write_status(f"npm is installed: v{stdout.strip()}", "SUCCESS")
    else:
        write_status("npm is not installed!", "ERROR")
        print("npm should come with Node.js. Please reinstall Node.js.")
        sys.exit(1)

    # Check Maven
    write_status("Checking Maven installation...")
    if test_command("mvn"):
        success, stdout, stderr = run_command("mvn --version")
        if success:
            write_status(f"Maven is installed: {stdout.splitlines()[0]}", "SUCCESS")
    else:
        write_status("Maven not found, will use Maven wrapper (mvnw)", "WARNING")

    # Find available ports
    write_status("Finding available ports...")
    backend_port = find_free_port(8082)
    frontend_port = find_free_port(3002)
    
    if backend_port:
        write_status(f"Backend will use port {backend_port}", "SUCCESS")
    else:
        write_status("Could not find available port for backend (tried 8082-8091)", "ERROR")
        sys.exit(1)
    
    if frontend_port:
        write_status(f"Frontend will use port {frontend_port}", "SUCCESS")
    else:
        write_status("Could not find available port for frontend (tried 3002-3011)", "ERROR")
        sys.exit(1)

    if test_port(27017):
        write_status("MongoDB appears to be running on port 27017", "SUCCESS")
    else:
        write_status("MongoDB is not detected on port 27017", "WARNING")
        print("You'll need to start MongoDB manually:")
        print("  - Install MongoDB Community Server: https://www.mongodb.com/try/download/community")
        print("  - Or use Docker: docker run -d --name mongodb -p 27017:27017 mongo:6.0")
        print("  - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas")

    print("")
    write_status("Setting up backend...")

    # Navigate to backend directory
    backend_dir = "backend"
    if not os.path.exists(backend_dir):
        write_status("Backend directory not found!", "ERROR")
        sys.exit(1)

    # Determine Maven command
    maven_cmd = None
    if test_command("mvn"):
        write_status("Using system Maven...")
        maven_cmd = "mvn"
    elif os.path.exists(os.path.join(backend_dir, "mvnw")):
        write_status("Using Maven wrapper...")
        maven_cmd = "./mvnw"
    else:
        write_status("Neither Maven wrapper nor system Maven is available!", "ERROR")
        print("Please install Maven or restore Maven wrapper files.")
        sys.exit(1)

    # Install dependencies and compile
    write_status(f"Installing backend dependencies and compiling with {maven_cmd}...", "INFO")
    write_status("This may take a few minutes on first run. Output will be shown below:", "INFO")
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    success, stdout, stderr = run_command(f"{maven_cmd} clean compile", cwd=backend_dir, shell=True, show_output=True)
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    if not success:
        write_status("Backend setup failed!", "ERROR")
        write_status(f"Maven command '{maven_cmd} clean compile' returned non-zero exit code", "ERROR")
        print(f"\n{Colors.YELLOW}Troubleshooting tips:{Colors.ENDC}")
        print(f"  1. Check if Java 17+ is properly installed: java -version")
        print(f"  2. Verify JAVA_HOME environment variable is set")
        print(f"  3. Try running manually: cd backend && {maven_cmd} clean compile")
        print(f"  4. Check for any compilation errors in the output above")
        sys.exit(1)
    write_status("Backend dependencies installed and compiled successfully", "SUCCESS")

    write_status("Setting up frontend...")

    # Navigate to frontend directory
    frontend_dir = "frontend"
    if not os.path.exists(frontend_dir):
        write_status("Frontend directory not found!", "ERROR")
        sys.exit(1)

    # Install dependencies
    write_status("Installing frontend dependencies...", "INFO")
    write_status("This may take a few minutes. Output will be shown below:", "INFO")
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    success, stdout, stderr = run_command("npm install", cwd=frontend_dir, shell=True, show_output=True)
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    if not success:
        write_status("Frontend setup failed!", "ERROR")
        print(f"\n{Colors.YELLOW}Troubleshooting tips:{Colors.ENDC}")
        print(f"  1. Check if Node.js and npm are properly installed")
        print(f"  2. Try running manually: cd frontend && npm install")
        print(f"  3. Clear npm cache: npm cache clean --force")
        print(f"  4. Delete node_modules and try again")
        sys.exit(1)
    write_status("Frontend dependencies installed successfully", "SUCCESS")

    # Build to verify setup
    write_status("Building frontend to verify setup...", "INFO")
    write_status("This may take a few minutes. Output will be shown below:", "INFO")
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    success, stdout, stderr = run_command("npm run build", cwd=frontend_dir, shell=True, show_output=True)
    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
    if success:
        write_status("Frontend built successfully", "SUCCESS")
    else:
        write_status("Frontend build failed!", "ERROR")
        print(f"\n{Colors.YELLOW}Troubleshooting tips:{Colors.ENDC}")
        print(f"  1. Try running 'npm install' again in the frontend directory")
        print(f"  2. Check for any build errors in the output above")
        print(f"  3. Try: cd frontend && npm run build")
        sys.exit(1)

    print("")
    write_status("Setup Complete!", "SUCCESS")
    print("")
    print("What was set up:")
    print("  - Backend (Spring Boot + Java 17+ + Maven)")
    print("  - Frontend (React + Node.js + npm)")
    print("")
    print("Next steps:")
    print("  python start.py start     # Start both services")
    print("  python start.py backend   # Start backend only")
    print("  python start.py frontend  # Start frontend only")
    print("")

def start_backend():
    """Start only the backend"""
    print(f"{Colors.BLUE}Starting Medium Blog Backend...{Colors.ENDC}")
    print(f"{Colors.BLUE}================================={Colors.ENDC}")
    print("")

    # Find available port
    write_status("Finding available port for backend...")
    backend_port = find_free_port(8082)
    if not backend_port:
        write_status("Could not find available port for backend (tried 8082-8091)", "ERROR")
        sys.exit(1)
    write_status(f"Using port {backend_port} for backend", "SUCCESS")

    # Check if MongoDB is running
    write_status("Checking MongoDB connection...")
    if test_port(27017):
        write_status("MongoDB is running on port 27017", "SUCCESS")
    else:
        write_status("MongoDB is not running on port 27017", "ERROR")
        print("Please start MongoDB first:")
        print("  - Open MongoDB Compass")
        print("  - Or run: docker run -d --name mongodb -p 27017:27017 mongo:6.0")
        input("Press Enter to continue anyway, or Ctrl+C to cancel...")

    # Navigate to backend directory
    backend_dir = "backend"
    if not os.path.exists(backend_dir):
        write_status("Backend directory not found!", "ERROR")
        sys.exit(1)

    # Check if Maven is available
    maven_cmd = None
    if test_command("mvn"):
        write_status("Using system Maven...")
        maven_cmd = "mvn"
    elif os.path.exists(os.path.join(backend_dir, "mvnw")):
        write_status("Using Maven wrapper...")
        maven_cmd = "./mvnw"
    else:
        write_status("Neither Maven nor Maven wrapper found!", "ERROR")
        print("Please install Maven or restore Maven wrapper files.")
        sys.exit(1)

    # Clean and compile backend first to ensure Lombok annotations are processed
    write_status("Compiling backend...", "INFO")
    success, stdout, stderr = run_command(f"{maven_cmd} clean compile", cwd=backend_dir, shell=True)
    if not success:
        write_status("Backend compilation failed!", "ERROR")
        print(f"\n{Colors.RED}=== Compilation Error ==={Colors.ENDC}")
        print(stderr)
        sys.exit(1)
    write_status("Backend compiled successfully", "SUCCESS")

    write_status("Starting Spring Boot application...")
    print(f"{Colors.CYAN}Backend will be available at: http://localhost:{backend_port}{Colors.ENDC}")
    print(f"{Colors.CYAN}API endpoints: http://localhost:{backend_port}/api{Colors.ENDC}")
    print("")
    print(f"{Colors.YELLOW}Press Ctrl+C to stop the backend{Colors.ENDC}")
    print("")

    # Start the backend with custom port
    env = os.environ.copy()
    env['SERVER_PORT'] = str(backend_port)
    try:
        subprocess.run(f"{maven_cmd} spring-boot:run", cwd=backend_dir, shell=True, env=env)
    except KeyboardInterrupt:
        print("\n")
        write_status("Backend stopped by user", "INFO")
    except Exception as e:
        write_status(f"Error starting backend: {e}", "ERROR")
        sys.exit(1)

def start_frontend():
    """Start only the frontend"""
    print(f"{Colors.BLUE}Starting Medium Blog Frontend...{Colors.ENDC}")
    print(f"{Colors.BLUE}=================================={Colors.ENDC}")
    print("")
    
    # Find available ports
    write_status("Finding available ports...")
    frontend_port = find_free_port(3002)
    backend_port = find_free_port(8082)
    
    if not frontend_port:
        write_status("Could not find available port for frontend (tried 3002-3011)", "ERROR")
        sys.exit(1)
    if not backend_port:
        write_status("Could not find available port for backend (tried 8082-8091)", "ERROR")
        sys.exit(1)
    
    write_status(f"Using port {frontend_port} for frontend", "SUCCESS")
    write_status(f"Backend is expected on port {backend_port}", "INFO")
    
    # Navigate to frontend directory
    frontend_dir = "frontend"
    if not os.path.exists(frontend_dir):
        write_status("Frontend directory not found!", "ERROR")
        sys.exit(1)

    # Check if node_modules exists
    if not os.path.exists(os.path.join(frontend_dir, "node_modules")):
        write_status("Installing frontend dependencies...")
        success, stdout, stderr = run_command("npm install", cwd=frontend_dir, shell=True)
        if not success:
            write_status("Failed to install frontend dependencies!", "ERROR")
            print(stderr)
            sys.exit(1)
        write_status("Frontend dependencies installed successfully", "SUCCESS")

    write_status("Starting React development server...")
    print(f"{Colors.CYAN}Frontend will be available at: http://localhost:{frontend_port}{Colors.ENDC}")
    print(f"{Colors.CYAN}Will connect to backend at: http://localhost:{backend_port}/api{Colors.ENDC}")
    print("")
    print(f"{Colors.YELLOW}Press Ctrl+C to stop the frontend{Colors.ENDC}")
    print("")

    # Start the frontend with custom port
    env = os.environ.copy()
    env['PORT'] = str(frontend_port)
    env['REACT_APP_API_URL'] = f'http://localhost:{backend_port}/api'
    try:
        subprocess.run("npm start", cwd=frontend_dir, shell=True, env=env)
    except KeyboardInterrupt:
        print("\n")
        write_status("Frontend stopped by user", "INFO")
    except Exception as e:
        write_status(f"Error starting frontend: {e}", "ERROR")
        sys.exit(1)

def check_url(url, timeout=2):
    """Check if a URL is accessible"""
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            return response.status == 200
    except:
        return False

def start_all():
    """Start both backend and frontend"""
    print(f"{Colors.BLUE}Starting Medium Blog Platform (All Services)...{Colors.ENDC}")
    print(f"{Colors.BLUE}==============================================={Colors.ENDC}")
    print("")

    # Find available ports
    write_status("Finding available ports...")
    backend_port = find_free_port(8082)
    frontend_port = find_free_port(3002)
    
    if not backend_port:
        write_status("Could not find available port for backend (tried 8082-8091)", "ERROR")
        sys.exit(1)
    if not frontend_port:
        write_status("Could not find available port for frontend (tried 3002-3011)", "ERROR")
        sys.exit(1)
    
    write_status(f"Backend will use port {backend_port}", "SUCCESS")
    write_status(f"Frontend will use port {frontend_port}", "SUCCESS")

    # Check if MongoDB is running
    write_status("Checking MongoDB connection...")
    if test_port(27017):
        write_status("MongoDB is running on port 27017", "SUCCESS")
    else:
        write_status("MongoDB is not running on port 27017", "ERROR")
        print("Please start MongoDB first:")
        print("  - Open MongoDB Compass")
        print("  - Or run: docker run -d --name mongodb -p 27017:27017 mongo:6.0")
        input("Press Enter to continue anyway, or Ctrl+C to cancel...")

    backend_process = None
    frontend_process = None
    backend_log = None
    frontend_log = None

    def cleanup(signum=None, frame=None):
        """Cleanup function to stop services"""
        print("\n")
        write_status("Stopping services...")
        
        if backend_process:
            write_status("Stopping backend...")
            try:
                backend_log.close()
            except:
                pass
            backend_process.terminate()
            try:
                backend_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                backend_process.kill()
        
        if frontend_process:
            write_status("Stopping frontend...")
            try:
                frontend_log.close()
            except:
                pass
            frontend_process.terminate()
            try:
                frontend_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                frontend_process.kill()
        
        write_status("Services stopped.", "SUCCESS")
        sys.exit(0)

    # Set up signal handlers
    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)

    write_status("Starting Backend...")

    # Determine Maven command
    backend_dir = "backend"
    maven_cmd = None
    if test_command("mvn"):
        maven_cmd = "mvn"
    elif os.path.exists(os.path.join(backend_dir, "mvnw")):
        maven_cmd = "./mvnw"
    else:
        write_status("Neither Maven nor Maven wrapper found!", "ERROR")
        sys.exit(1)

    # Clean and compile backend first to ensure Lombok annotations are processed
    write_status("Compiling backend (this may take a moment)...", "INFO")
    success, stdout, stderr = run_command(f"{maven_cmd} clean compile", cwd=backend_dir, shell=True)
    if not success:
        write_status("Backend compilation failed!", "ERROR")
        print(f"\n{Colors.RED}=== Compilation Error ==={Colors.ENDC}")
        print(stderr)
        sys.exit(1)
    write_status("Backend compiled successfully", "SUCCESS")

    # Start backend in background with custom port
    backend_env = os.environ.copy()
    backend_env['SERVER_PORT'] = str(backend_port)
    
    # Create a log file for backend output
    backend_log_file = os.path.join(backend_dir, "startup.log")
    try:
        backend_log = open(backend_log_file, 'w')
        backend_process = subprocess.Popen(
            f"{maven_cmd} spring-boot:run",
            cwd=backend_dir,
            shell=True,
            stdout=backend_log,
            stderr=subprocess.STDOUT,
            env=backend_env
        )
        write_status(f"Backend logs: {os.path.abspath(backend_log_file)}", "INFO")
    except Exception as e:
        write_status(f"Error starting backend: {e}", "ERROR")
        sys.exit(1)

    write_status("Waiting for backend to start...")
    backend_started = False
    for i in range(30):
        if check_url(f"http://localhost:{backend_port}/api/posts"):
            write_status(f"Backend is running on http://localhost:{backend_port}", "SUCCESS")
            backend_started = True
            break
        time.sleep(2)
        print(".", end="", flush=True)

    if not backend_started:
        print("")
        write_status("Backend failed to start within 60 seconds", "ERROR")
        write_status("Reading backend logs...", "INFO")
        backend_log.close()
        
        # Read and display the log file
        try:
            with open(backend_log_file, 'r') as log:
                log_contents = log.read()
                if log_contents:
                    print(f"\n{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                    print(f"{Colors.RED}Backend Startup Logs (last 100 lines):{Colors.ENDC}")
                    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                    # Show last 100 lines
                    lines = log_contents.splitlines()
                    for line in lines[-100:]:
                        print(line)
                    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                else:
                    write_status("No logs generated yet", "WARNING")
        except Exception as e:
            write_status(f"Could not read log file: {e}", "ERROR")
        
        cleanup()

    print("")
    write_status("Starting Frontend...")

    # Start frontend in background
    frontend_dir = "frontend"
    
    # Check if node_modules exists
    if not os.path.exists(os.path.join(frontend_dir, "node_modules")):
        write_status("Installing frontend dependencies...")
        success, stdout, stderr = run_command("npm install", cwd=frontend_dir, shell=True)
        if not success:
            write_status("Failed to install frontend dependencies!", "ERROR")
            cleanup()

    # Set up frontend environment with custom port
    frontend_env = os.environ.copy()
    frontend_env['PORT'] = str(frontend_port)
    frontend_env['REACT_APP_API_URL'] = f'http://localhost:{backend_port}/api'
    
    # Create a log file for frontend output
    frontend_log_file = os.path.join(frontend_dir, "startup.log")
    try:
        frontend_log = open(frontend_log_file, 'w')
        frontend_process = subprocess.Popen(
            "npm start",
            cwd=frontend_dir,
            shell=True,
            stdout=frontend_log,
            stderr=subprocess.STDOUT,
            env=frontend_env
        )
        write_status(f"Frontend logs: {os.path.abspath(frontend_log_file)}", "INFO")
    except Exception as e:
        write_status(f"Error starting frontend: {e}", "ERROR")
        cleanup()

    write_status("Waiting for frontend to start...")
    frontend_started = False
    for i in range(30):
        if check_url(f"http://localhost:{frontend_port}"):
            write_status(f"Frontend is running on http://localhost:{frontend_port}", "SUCCESS")
            frontend_started = True
            break
        time.sleep(2)
        print(".", end="", flush=True)

    if not frontend_started:
        print("")
        write_status("Frontend failed to start within 60 seconds", "ERROR")
        write_status("Reading frontend logs...", "INFO")
        frontend_log.close()
        
        # Read and display the log file
        try:
            with open(frontend_log_file, 'r') as log:
                log_contents = log.read()
                if log_contents:
                    print(f"\n{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                    print(f"{Colors.RED}Frontend Startup Logs (last 100 lines):{Colors.ENDC}")
                    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                    # Show last 100 lines
                    lines = log_contents.splitlines()
                    for line in lines[-100:]:
                        print(line)
                    print(f"{Colors.YELLOW}{'='*60}{Colors.ENDC}")
                else:
                    write_status("No logs generated yet", "WARNING")
        except Exception as e:
            write_status(f"Could not read log file: {e}", "ERROR")

    print("")
    write_status("Medium Blog Platform is running!", "SUCCESS")
    print(f"{Colors.GREEN}================================={Colors.ENDC}")
    print("")
    print(f"{Colors.CYAN}Frontend: http://localhost:{frontend_port}{Colors.ENDC}")
    print(f"{Colors.CYAN}Backend API: http://localhost:{backend_port}/api{Colors.ENDC}")
    print(f"{Colors.CYAN}Database: MongoDB on localhost:27017{Colors.ENDC}")
    print("")
    print(f"{Colors.YELLOW}Sample Login Credentials:{Colors.ENDC}")
    print(f"{Colors.WHITE}   Username: john_doe | Password: demo123{Colors.ENDC}")
    print(f"{Colors.WHITE}   Username: jane_smith | Password: demo123{Colors.ENDC}")
    print("")
    print(f"{Colors.RED}To stop all services: Press Ctrl+C{Colors.ENDC}")
    print("")

    # Keep script running
    print(f"{Colors.GREEN}Services are running. Press Ctrl+C to stop all services...{Colors.ENDC}")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        cleanup()

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Medium Blog Platform - Unified Setup and Start Script",
        add_help=False
    )
    parser.add_argument('command', nargs='?', choices=['setup', 'start', 'backend', 'frontend', 'help'],
                       help='Command to execute')
    
    args = parser.parse_args()

    if args.command == 'help' or args.command is None:
        show_help()
    elif args.command == 'setup':
        invoke_setup()
    elif args.command == 'backend':
        start_backend()
    elif args.command == 'frontend':
        start_frontend()
    elif args.command == 'start':
        start_all()

if __name__ == "__main__":
    main()

