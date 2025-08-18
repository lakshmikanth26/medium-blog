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
- **Node.js 18+** (for React frontend)
- **MongoDB 6.0+** (database)
- **npm** (Node Package Manager)

### Quick Start (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medium-blog
   ```

2. **Start all services with automatic database setup**
   ```bash
   ./start.sh
   ```
   
   The start script will:
   - Check all prerequisites
   - Verify MongoDB is running
   - Run database migration on first time setup
   - Start backend and frontend services
   - Show sample login credentials

3. **Access the application**
   - 🌐 **Frontend**: http://localhost:3000
   - 🔧 **Backend API**: http://localhost:8080/api
   - 🗄️ **Database**: MongoDB on localhost:27017

4. **Sample Login Credentials**
   - Username: `john_doe` | Password: `demo123`
   - Username: `jane_smith` | Password: `demo123`

### MongoDB Setup

Before running the application, ensure MongoDB is running on localhost:27017:

**Option A: Homebrew (macOS)**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

**Option B: Docker**
```bash
docker run -d --name mongodb -p 27017:27017 mongo:6.0
```

**Option C: MongoDB Compass**
- Download and install [MongoDB Compass](https://www.mongodb.com/products/compass)
- Start the MongoDB service through Compass

**Option D: Local Installation**
```bash
mongod --dbpath /usr/local/var/mongodb
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

### Managing Services

```bash
# Start all services (with migration on first run)
./start.sh

# Stop all services
./stop.sh

# Run only database migration
npm run migrate
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
├── start.sh                 # Start all services
├── stop.sh                  # Stop all services
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
   - Ensure MongoDB is running on port 27017
   - Check if MongoDB service is started
   - Try: `brew services restart mongodb-community`

2. **Port Already in Use**
   - Backend (8080): Stop any existing Spring Boot applications
   - Frontend (3000): Stop any existing React development servers
   - MongoDB (27017): Check for existing MongoDB instances

3. **Migration Failed**
   - Ensure MongoDB is running before running migration
   - Check Node.js version (recommended 18+)
   - Verify npm install completed successfully

4. **Backend Won't Start**
   - Check Java version: `java -version` (needs 17+)
   - View logs: `tail -f backend.log`
   - Verify MongoDB connection

5. **Frontend Won't Start**
   - Check Node.js version: `node -v` (needs 18+)
   - Clear node_modules: `rm -rf frontend/node_modules && cd frontend && npm install`
   - View logs: `tail -f frontend.log`

### Useful Commands

```bash
# Check service status
./start.sh  # Shows service URLs and status

# View real-time logs
tail -f backend.log    # Backend logs
tail -f frontend.log   # Frontend logs

# Check if services are running
lsof -i :3000         # Frontend
lsof -i :8080         # Backend
lsof -i :27017        # MongoDB

# Clean restart
./stop.sh
rm -f .migration_completed  # Force migration re-run
./start.sh
```

## 🎉 What's New

- ✅ **Removed Docker Compose**: Simplified setup with direct local development
- ✅ **Database Migration**: Automatic database setup with sample data
- ✅ **Read Count Tracking**: Stories automatically track view counts
- ✅ **Better Error Messages**: Specific login error feedback
- ✅ **Loading Indicators**: Smooth UX during authentication
- ✅ **Fixed Publish UI**: Resolved CSS issues with publish checkbox

## 📝 License

MIT License - see LICENSE file for details.

---

🚀 **Ready to start blogging!** Run `./start.sh` and visit http://localhost:3000