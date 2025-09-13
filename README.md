# Medium-like Blogging Platform

A full-stack blogging platform built with Spring Boot and React, featuring a modern Medium-like interface.

## ✨ Features

### 🔧 Backend (Spring Boot)
- User authentication with JWT
- CRUD operations for blog posts  
- Like and comment functionality
- Tagging system
- Search and pagination
- Read count tracking
- Draft/publish workflow
- Clean architecture (Controller, Service, Repository)

### 🌐 Frontend (React)
- Modern Medium-like UI with TailwindCSS
- User authentication forms with loading states
- Rich text editor for posts
- Infinite scroll feed
- Single post view with comments
- User profile pages
- Proper error handling

### 📊 New Features
- **Read Count Increment**: Automatically tracks when stories are opened
- **Better Login Error Messages**: Shows specific error messages for wrong credentials
- **Loading Indicators**: Loading spinners for login/logout operations
- **Publish Immediately**: Fixed CSS issues with the publish checkbox

## 🛠️ Tech Stack

### Backend
- **Framework**: Spring Boot 3.x
- **Database**: MongoDB
- **Authentication**: JWT
- **Build Tool**: Maven

### Frontend
- **Framework**: React 18
- **Styling**: TailwindCSS
- **State Management**: React Context
- **HTTP Client**: Axios
- **Rich Text Editor**: React Quill

## 🚀 Getting Started

### Prerequisites

- **Java 17+** (for Spring Boot backend)
- **Node.js 16+** (for React frontend) 
- **MongoDB 6.0+** (database)
- **npm** (Node Package Manager)

### 🎯 First-Time Setup (Choose Your Platform)

#### **Option A: Automatic Setup (Recommended)**

##### **Windows Users**
```cmd
# Option 1: PowerShell (Recommended)
.\setup.ps1

# Option 2: Command Prompt  
setup.bat

# Option 3: With PowerShell options
.\setup.ps1 -SkipTests          # Skip backend tests
.\setup.ps1 -Verbose            # Show detailed logs
.\setup.ps1 -Help               # Show help information
```

##### **Linux/macOS Users**
```bash
# Run the setup script
./setup.sh
```

The setup scripts will:
- ✅ Check all system prerequisites
- ✅ Install and compile backend dependencies
- ✅ Install frontend dependencies
- ✅ Create environment configuration files
- ✅ Set up database migration scripts
- ✅ Create comprehensive error logs
- ✅ Handle missing Maven wrapper files automatically

#### **Option B: Manual Setup**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medium-blog
   ```

2. **Run first-time setup** (choose your platform above)

3. **Access the application**
   - 🌐 **Frontend**: http://localhost:3000
   - 🔧 **Backend API**: http://localhost:8080/api
   - 🗄️ **Database**: MongoDB on localhost:27017

4. **Sample Login Credentials**
   - Username: `john_doe` | Password: `demo123`
   - Username: `jane_smith` | Password: `demo123`

### MongoDB Setup

Before running the application, ensure MongoDB is running on localhost:27017:

#### **Windows**
```cmd
# Option 1: Install MongoDB Community Server
# Download from: https://www.mongodb.com/try/download/community
# Follow the installation wizard

# Option 2: Using winget
winget install MongoDB.Server

# Option 3: Docker
docker run -d --name mongodb -p 27017:27017 mongo:6.0

# Option 4: MongoDB Compass (GUI)
# Download from: https://www.mongodb.com/products/compass
```

#### **macOS**
```bash
# Option 1: Homebrew (Recommended)
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community

# Option 2: Docker
docker run -d --name mongodb -p 27017:27017 mongo:6.0
```

#### **Linux (Ubuntu/Debian)**
```bash
# Option 1: Official Package
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod

# Option 2: Docker
docker run -d --name mongodb -p 27017:27017 mongo:6.0
```

### Manual Setup (Alternative)

1. **Start MongoDB** (see options above)

2. **Run Database Migration** (First time only)
   ```bash
   npm install
   npm run migrate
   ```

3. **Start Backend**
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```

4. **Start Frontend** (in another terminal)
   ```bash
   cd frontend
   npm install
   npm start
   ```

### 🎮 Managing Services

#### **Windows**
```cmd
# Start all services
start.bat                    # Batch script
# OR use the Unix-style scripts with Git Bash
./start.sh

# Stop all services  
stop.bat                     # Forcefully stops all Java and Node processes
./stop.sh                    # Unix-style (Git Bash)

# Setup/Re-setup
setup.bat                    # Batch script setup
.\setup.ps1                  # PowerShell script (recommended)
./setup.sh                   # Unix-style (Git Bash)
```

#### **Linux/macOS**
```bash  
# Start all services (with migration on first run)
./start.sh

# Stop all services
./stop.sh

# First-time setup or re-setup
./setup.sh

# Run only database migration
npm run migrate
```

#### **Cross-Platform Options**
```bash
# Manual backend start
cd backend && ./mvnw spring-boot:run    # Linux/macOS
cd backend && mvnw.cmd spring-boot:run  # Windows

# Manual frontend start  
cd frontend && npm start                # All platforms
```

## 📁 Project Structure

```
medium-blog/
├── backend/                 # Spring Boot application
│   ├── src/main/java/com/blog/
│   │   ├── controller/      # REST controllers
│   │   ├── service/         # Business logic
│   │   ├── repository/      # Data access
│   │   ├── model/           # Entity models
│   │   ├── dto/             # Data transfer objects
│   │   ├── config/          # Configuration classes
│   │   └── security/        # Security & JWT
│   └── pom.xml
├── frontend/                # React application
│   ├── src/
│   │   ├── components/      # Reusable components
│   │   ├── pages/           # Page components
│   │   ├── context/         # React contexts
│   │   ├── services/        # API services
│   │   └── utils/           # Utility functions
│   └── package.json
├── migrate.js               # Database migration script
├── package.json             # Migration dependencies
├── start.sh                 # Start all services (Unix/Linux/macOS)
├── stop.sh                  # Stop all services (Unix/Linux/macOS)
├── setup.sh                 # First-time setup (Unix/Linux/macOS)
├── start.bat                # Start all services (Windows)
├── stop.bat                 # Stop all services (Windows)  
├── setup.bat                # First-time setup (Windows Batch)
├── setup.ps1                # First-time setup (Windows PowerShell)
├── .env.example             # Environment configuration template
└── README.md
```

## 📋 API Endpoints

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login

### Posts
- `GET /api/posts` - Get all posts (with pagination)
- `GET /api/posts/{id}` - Get single post (increments read count)
- `POST /api/posts` - Create new post
- `POST /api/posts/{id}/publish` - Publish a draft post
- `PUT /api/posts/{id}` - Update post
- `DELETE /api/posts/{id}` - Delete post
- `POST /api/posts/{id}/like` - Like/unlike post
- `POST /api/posts/{id}/comments` - Add comment

### Users
- `GET /api/users/profile` - Get user profile
- `GET /api/users/{id}/posts` - Get user's posts (includes drafts)

## 🗄️ Database Migration

The platform includes an automatic migration system:

### What the Migration Does
- **Creates Database Indexes**: Optimizes query performance
- **Sample Users**: Creates demo accounts for testing
- **Sample Posts**: Creates example blog posts and drafts
- **Database Structure**: Sets up proper collections and relationships

### Migration Features
- **First-Time Setup**: Runs automatically when starting with `./start.sh`
- **Idempotent**: Safe to run multiple times
- **Sample Data**: Includes demo users and posts for immediate testing
- **Progress Tracking**: Uses a migrations collection to track completion

### Manual Migration
```bash
# Install dependencies
npm install

# Run migration manually
npm run migrate

# Or run directly
node migrate.js
```

## 🎨 Key Features

### User Experience
- Clean, modern Medium-like interface
- Responsive design for all devices
- Loading indicators for better UX
- Proper error handling with specific messages

### Content Management
- Rich text editor with formatting options
- Draft and publish workflow
- Tag system for categorization
- Read count tracking
- "Publish immediately" option

### Social Features
- Like/unlike posts
- Comment system
- User profiles
- Post statistics (reads, likes, comments)

## 🔧 Environment Configuration

The application uses the following default configurations:

### Backend (Spring Boot)
```yaml
# application.yml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/medium-blog
server:
  port: 8080
jwt:
  secret: your-secret-key
  expiration: 86400000
```

### Frontend (React)
```javascript
// Default API URL
REACT_APP_API_URL=http://localhost:8080/api
```

## 🐛 Troubleshooting

### Common Issues

1. **MongoDB Connection Failed**
   - **Windows**: Check if MongoDB service is running in Services.msc
   - **macOS**: Try `brew services restart mongodb-community`
   - **Linux**: Try `sudo systemctl start mongod`
   - **Docker**: `docker start mongodb`

2. **Port Already in Use**
   - **Backend (8080)**: Stop existing Spring Boot applications
     - Windows: Check Task Manager for Java processes
     - Unix: `lsof -i :8080` then `kill <PID>`
   - **Frontend (3000)**: Stop existing React servers
     - Windows: Check Task Manager for Node processes  
     - Unix: `lsof -i :3000` then `kill <PID>`

3. **Setup Script Fails**
   - Check logs in `logs/` directory:
     - `logs/setup.log` - Complete setup log
     - `logs/setup-error.log` - Error messages only
     - `logs/setup-backend.log` - Backend compilation
     - `logs/setup-frontend.log` - Frontend installation
   - **Windows**: Try running as Administrator
   - **PowerShell**: Try `Set-ExecutionPolicy RemoteSigned` if script won't run

4. **Java/Maven Issues** 
   - Check Java version: `java -version` (needs 17+)
   - **Maven wrapper missing**: Setup scripts automatically recreate them
   - **Windows**: Use `mvnw.cmd` instead of `./mvnw`

5. **Node.js/npm Issues**
   - Check Node.js version: `node -v` (needs 16+) 
   - Clear cache: `npm cache clean --force`
   - **Windows**: Clear node_modules: `rmdir /s frontend\node_modules`
   - **Unix**: `rm -rf frontend/node_modules && cd frontend && npm install`

### 📋 Log Files & Debugging

#### **Windows**
```cmd
# View logs (PowerShell)
Get-Content logs\setup.log -Tail 20
Get-Content logs\setup-error.log

# Check running processes
tasklist | findstr java
tasklist | findstr node

# Check ports
netstat -an | findstr :8080
netstat -an | findstr :3000
netstat -an | findstr :27017
```

#### **Linux/macOS**  
```bash
# View real-time logs
tail -f logs/setup.log      # Complete setup log
tail -f logs/setup-error.log # Error messages only

# Check if services are running  
lsof -i :3000         # Frontend
lsof -i :8080         # Backend
lsof -i :27017        # MongoDB

# Process management
ps aux | grep java    # Backend processes
ps aux | grep node    # Frontend processes
```

### 🔧 Clean Restart Process

#### **Windows**
```cmd
# Complete clean restart
stop.bat
rmdir /s /q logs
setup.bat
start.bat
```

#### **Linux/macOS**
```bash  
# Complete clean restart
./stop.sh
rm -rf logs .migration_completed
./setup.sh
./start.sh
```

## 🎉 What's New

### Recent Updates
- ✅ **Full Windows Support**: Comprehensive Windows setup with `.bat` and `.ps1` scripts
- ✅ **Enhanced Error Logging**: Detailed logs in `logs/` directory for debugging
- ✅ **Cross-Platform Setup**: Automated first-time setup for Windows, macOS, and Linux
- ✅ **Maven Wrapper Recovery**: Automatically recreates missing Maven wrapper files
- ✅ **Better Prerequisites Checking**: Validates Java, Node.js, npm, and MongoDB before setup
- ✅ **Improved Documentation**: Platform-specific instructions and troubleshooting

### Previous Updates  
- ✅ **Removed Docker Compose**: Simplified setup with direct local development
- ✅ **Database Migration**: Automatic database setup with sample data
- ✅ **Read Count Tracking**: Stories automatically track view counts
- ✅ **Better Error Messages**: Specific login error feedback
- ✅ **Loading Indicators**: Smooth UX during authentication
- ✅ **Fixed Publish UI**: Resolved CSS issues with publish checkbox

## 📝 License

MIT License - see LICENSE file for details.

---

## 🚀 Quick Start Summary

### **First Time Setup**
```cmd
# Windows users (choose one):
setup.bat           # Batch script  
.\setup.ps1         # PowerShell (recommended)

# Linux/macOS users:
./setup.sh          # Bash script
```

### **Start Application**
```cmd
# Windows:
start.bat           # Batch script
./start.sh          # Git Bash

# Linux/macOS:
./start.sh          # Bash script
```

### **Access Your Blog**
- 🌐 **Frontend**: http://localhost:3000
- 🔧 **Backend**: http://localhost:8080/api
- 👤 **Login**: `john_doe` / `demo123`

---

🚀 **Ready to start blogging!** Choose your platform setup above and visit http://localhost:3000