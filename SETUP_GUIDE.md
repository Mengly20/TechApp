# EdTech Scanner - Complete Setup Guide

## 📱 Step 3: Connect Flutter App to Backend API

### What This Means
Your Flutter app needs to communicate with the backend server to:
- Authenticate users (Google, Phone, Guest)
- Analyze images using AI
- Get equipment information
- Save scan history to cloud
- Chat with AI assistant

### What I Already Did For You ✅
I updated the file `edtech_scanner/lib/core/constants/api_constants.dart` to point to your local backend:

```dart
static const String baseUrl = 'http://localhost:8000/api';
```

### How It Works

**Before (Mock Mode):**
```
Flutter App → Mock Data → Display to User
```

**After (Connected to Backend):**
```
Flutter App → HTTP Request → Backend API → Database → Response → Display to User
```

### Testing the Connection

#### For Web (What you're using now):
1. ✅ Backend running at: `http://localhost:8000`
2. ✅ Flutter app running at: `http://localhost:8080`
3. ✅ Already configured correctly!

Just reload your Flutter app and it will connect to the backend.

#### For Android Emulator:
If you run on Android emulator, change the URL to:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```
Because Android emulator can't access `localhost`, use `10.0.2.2` instead.

#### For iOS Simulator:
Keep it as:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```
iOS simulator can access localhost directly.

#### For Real Android/iOS Device:
Change to your computer's IP address:
```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```
Replace `192.168.1.100` with your actual computer IP address.
Find your IP with: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

---

## 🚀 Step 4: Production Deployment (Docker Compose)

### What This Means
Right now, you're running in **development mode**:
- Using SQLite (small file database)
- Using in-memory cache (data lost on restart)
- Running on localhost (only you can access)

For **production mode**, you need:
- PostgreSQL (professional database, handles millions of users)
- Redis (fast cache server)
- Docker (packages everything together)

### Development vs Production

| Feature | Development (Now) | Production (Deploy) |
|---------|------------------|---------------------|
| Database | SQLite (file) | PostgreSQL (server) |
| Cache | In-memory | Redis (server) |
| Access | localhost only | Internet accessible |
| Data | Lost on restart | Persistent |
| Users | 1-10 | Unlimited |
| Speed | Good | Very Fast |

### How to Deploy with Docker Compose

#### What is Docker?
Docker is like a shipping container for your app. It packages:
- Your code
- Python
- Database
- Cache
- Everything needed to run

#### What is Docker Compose?
Docker Compose runs multiple containers together:
- **Container 1**: PostgreSQL database
- **Container 2**: Redis cache
- **Container 3**: Your FastAPI backend

They all talk to each other automatically!

### Step-by-Step Production Deployment

#### 1. Install Docker Desktop
Download from: https://www.docker.com/products/docker-desktop/
- For Windows: Install Docker Desktop for Windows
- For Mac: Install Docker Desktop for Mac

#### 2. Start Docker Desktop
- Open Docker Desktop application
- Wait for it to say "Docker is running"

#### 3. Navigate to backend folder
```bash
cd d:\BBU\CADT\SceondWindsurf\backend
```

#### 4. Update .env file for production
Edit `backend/.env`:
```env
# Change these for production
ENVIRONMENT=production
DEBUG=False

# Use strong secret key
SECRET_KEY=your-super-secret-production-key-change-this-now

# Add your real API keys
GOOGLE_CLIENT_ID=your-google-oauth-client-id
GEMINI_API_KEY=your-gemini-api-key
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
```

#### 5. Start everything with one command
```bash
docker-compose up -d
```

This command:
- Downloads PostgreSQL image
- Downloads Redis image
- Builds your backend image
- Starts all 3 containers
- Connects them together

#### 6. Check if it's running
```bash
docker-compose ps
```

You should see:
```
NAME                STATUS
edtech_postgres     Up
edtech_redis        Up
edtech_api          Up
```

#### 7. View logs
```bash
docker-compose logs -f api
```

#### 8. Stop everything
```bash
docker-compose down
```

### What Happens When You Deploy

```
┌─────────────────────────────────────┐
│       Docker Compose Network        │
│                                     │
│  ┌──────────────┐                  │
│  │ PostgreSQL   │ Port 5432        │
│  │ Database     │◄─────┐           │
│  └──────────────┘      │           │
│                        │           │
│  ┌──────────────┐      │           │
│  │ Redis Cache  │ Port 6379        │
│  │              │◄─────┼───┐       │
│  └──────────────┘      │   │       │
│                        │   │       │
│  ┌──────────────┐      │   │       │
│  │ FastAPI      │──────┘   │       │
│  │ Backend      │──────────┘       │
│  │ Port 8000    │◄─────────────────┼─── Internet
│  └──────────────┘                  │
│                                     │
└─────────────────────────────────────┘
```

### Real-World Production Deployment

For actual production (serving users on internet):

#### Option 1: Cloud Platform (Easiest)
Deploy to cloud platforms that support Docker:
- **Railway** (easiest, free tier): https://railway.app/
- **Render** (free tier): https://render.com/
- **Fly.io** (free tier): https://fly.io/
- **Google Cloud Run**
- **AWS ECS**
- **Azure Container Apps**

#### Option 2: VPS (Virtual Private Server)
Rent a server and deploy:
- **DigitalOcean** ($5/month)
- **Linode** ($5/month)
- **AWS EC2**
- **Google Cloud Compute Engine**

Steps for VPS:
1. Rent a server
2. Install Docker
3. Upload your code
4. Run `docker-compose up -d`
5. Configure domain name
6. Set up SSL certificate (https)
7. Configure firewall

### Example: Deploy to Railway.app (Free!)

1. Create account at https://railway.app/
2. Install Railway CLI:
```bash
npm install -g @railway/cli
```

3. Login:
```bash
railway login
```

4. Deploy:
```bash
cd backend
railway up
```

5. Railway will:
   - Create PostgreSQL database automatically
   - Create Redis automatically
   - Deploy your backend
   - Give you a public URL like: `https://your-app.up.railway.app`

6. Update Flutter app with new URL:
```dart
static const String baseUrl = 'https://your-app.up.railway.app/api';
```

Done! Your app is now live on the internet! 🎉

---

## 🔍 Understanding the Architecture

### Current Setup (Development)
```
Your Computer
├── Flutter App (localhost:8080)
│   └── Makes HTTP requests to ↓
└── Backend Server (localhost:8000)
    ├── SQLite Database (file: edtech_scanner.db)
    └── In-Memory Cache
```

### Production Setup (Docker Compose)
```
Docker Network
├── Backend Container (port 8000)
│   └── Connects to ↓
├── PostgreSQL Container (port 5432)
└── Redis Container (port 6379)

↓ All accessible from Internet
```

---

## 📋 Quick Reference

### Start Backend (Development)
```bash
cd backend
python run_dev.py
```

### Start Backend (Production with Docker)
```bash
cd backend
docker-compose up -d
```

### Start Flutter App
```bash
cd edtech_scanner
flutter run -d chrome --web-port=8080
```

### Check Backend is Working
Open browser: http://localhost:8000/docs
You should see API documentation

### Update Flutter to Use Backend
Already done! File updated at:
`edtech_scanner/lib/core/constants/api_constants.dart`

---

## 🛠️ Troubleshooting

### "Can't connect to backend"
1. Check backend is running: http://localhost:8000/health
2. Check CORS settings in backend `.env`
3. Check Flutter app URL in `api_constants.dart`

### "Docker command not found"
Install Docker Desktop from https://www.docker.com/

### "Port 8000 already in use"
Stop the dev server first:
- Press CTRL+C in terminal where backend is running
- Or change port in docker-compose.yml

### "Database errors"
Delete the database file and restart:
```bash
rm backend/edtech_scanner.db
python backend/run_dev.py
```

---

## 📞 Need Help?

- Backend API Docs: http://localhost:8000/docs
- Backend Health: http://localhost:8000/health
- Flutter App: http://localhost:8080

Everything is configured and ready to go! 🚀
