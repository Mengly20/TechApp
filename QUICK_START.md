# 🚀 Quick Start - EdTech Scanner

## What You Have Now

✅ **Flutter App** - Running at http://localhost:8080
✅ **Backend API** - Running at http://localhost:8000  
✅ **Database** - SQLite with 5 equipment items
✅ **API Docs** - http://localhost:8000/docs

## ✨ They're Already Connected!

I already updated your Flutter app to connect to the backend. Here's what changed:

### Before:
```dart
// Old - pointed to fake production server
static const String baseUrl = 'https://api.edtech-scanner.com/api/v1';
```

### After:
```dart
// New - points to your local backend
static const String baseUrl = 'http://localhost:8000/api';
```

**Location:** `edtech_scanner/lib/core/constants/api_constants.dart`

---

## 🧪 Test It Right Now!

### 1. Check Backend is Running
Open in browser: http://localhost:8000

You should see:
```json
{
  "message": "Welcome to EdTech Scanner API",
  "version": "1.0.0",
  "docs": "/docs",
  "health": "/health"
}
```

### 2. View API Documentation
Open: http://localhost:8000/docs

This shows all API endpoints you can use!

### 3. Test an Endpoint
Open: http://localhost:8000/api/equipment/list

You should see your 5 equipment items in JSON format.

### 4. Reload Flutter App
1. Go to your Flutter app (http://localhost:8080)
2. Press `R` or reload the page
3. The app now uses real backend data!

---

## 📱 Different Platforms = Different URLs

### Web (Current - Already Working!)
```dart
static const String baseUrl = 'http://localhost:8000/api';
```
✅ No changes needed!

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```
📱 Android emulator uses special IP `10.0.2.2` for localhost

### iOS Simulator  
```dart
static const String baseUrl = 'http://localhost:8000/api';
```
📱 Same as web

### Real Phone (Android/iOS)
```dart
static const String baseUrl = 'http://YOUR-COMPUTER-IP:8000/api';
```
📱 Replace with your actual IP address

**Find your IP:**
- Windows: Open CMD, type `ipconfig`, look for "IPv4 Address"
- Mac/Linux: Open Terminal, type `ifconfig`, look for "inet"
- Example: `192.168.1.100`

---

## 🐳 Docker Compose Explained Simply

### What You're Doing Now (Development):
```
You run Python manually:
  python run_dev.py → Starts backend
  
Problems:
  ❌ Need Python installed
  ❌ Need PostgreSQL installed  
  ❌ Need Redis installed
  ❌ Manual setup on each computer
  ❌ Different versions cause issues
```

### What Docker Compose Does (Production):
```
You run one command:
  docker-compose up → Starts EVERYTHING

Benefits:
  ✅ No Python installation needed
  ✅ No PostgreSQL installation needed
  ✅ No Redis installation needed
  ✅ One command on any computer
  ✅ Same environment everywhere
  ✅ Professional production setup
```

### Docker Compose Is Like:
Imagine you're shipping a computer:
- **Without Docker**: Ship parts separately (motherboard, RAM, CPU, etc.)
  - Recipient has to assemble everything
  - Might get wrong parts
  - Complex setup
  
- **With Docker**: Ship complete working computer
  - Recipient just plugs it in
  - Everything works instantly
  - Same setup everywhere

---

## 🎯 When to Use What

### Use Development Mode (Current) When:
- ✅ Building features
- ✅ Testing locally
- ✅ Learning
- ✅ Quick changes
- ✅ Only you need access

**Command:**
```bash
cd backend
python run_dev.py
```

### Use Docker Compose When:
- ✅ Deploying to server
- ✅ Multiple developers working together
- ✅ Production environment
- ✅ Need real PostgreSQL
- ✅ Need data persistence
- ✅ Users accessing from internet

**Command:**
```bash
cd backend
docker-compose up -d
```

---

## 📊 Current vs Production Comparison

| Feature | Current (Dev) | Production (Docker) |
|---------|---------------|---------------------|
| **Database** | SQLite file | PostgreSQL server |
| **Setup** | Manual Python | One Docker command |
| **Data** | Lost on crash | Persistent |
| **Speed** | Good | Excellent |
| **Users** | You only | Thousands |
| **Scale** | Small | Enterprise |
| **Cost** | Free | Free (local) |
| **Deploy Time** | 5 minutes | 1 minute |
| **Requirements** | Python, packages | Docker only |

---

## 🎓 Simple Docker Commands

### Install Docker
Download: https://www.docker.com/products/docker-desktop/
- Install Docker Desktop
- Start Docker Desktop
- Wait for green "Docker is running"

### Start Everything
```bash
cd backend
docker-compose up -d
```
- Downloads images (first time only)
- Starts PostgreSQL
- Starts Redis  
- Starts Backend
- All connected automatically!

### Check Status
```bash
docker-compose ps
```
Should show 3 services running.

### View Logs
```bash
docker-compose logs -f api
```
See what backend is doing.

### Stop Everything
```bash
docker-compose down
```
Stops all services cleanly.

### Start Again
```bash
docker-compose up -d
```
Restarts with saved data.

### Delete Everything & Start Fresh
```bash
docker-compose down -v
docker-compose up -d
```
Removes all data and starts clean.

---

## 🌐 Deploy to Internet (Free!)

### Option 1: Railway.app (Recommended)
1. Go to https://railway.app/
2. Sign up (free)
3. Click "New Project"
4. Connect your GitHub (push your code)
5. Railway auto-deploys!
6. Get URL like: `https://yourapp.up.railway.app`

### Option 2: Render.com
1. Go to https://render.com/
2. Sign up (free)
3. New → Web Service
4. Connect GitHub
5. Select "Docker" 
6. Deploy!

### Option 3: Fly.io
```bash
# Install Fly CLI
npm install -g @flyctl/cli

# Login
fly auth login

# Deploy
cd backend
fly launch
fly deploy
```

### After Deploying, Update Flutter:
```dart
// In api_constants.dart
static const String baseUrl = 'https://yourapp.up.railway.app/api';
```

Rebuild Flutter app and it works worldwide! 🌍

---

## ✅ Everything Is Ready!

Your system is **fully functional** right now:
- ✅ Backend API running
- ✅ Database with sample data
- ✅ Flutter app connected
- ✅ Mock AI working
- ✅ All endpoints ready

**Just reload your Flutter app and start using it!**

---

## 🆘 Quick Troubleshooting

### Backend won't start
```bash
# Make sure no other process is using port 8000
# Windows:
netstat -ano | findstr :8000

# Kill if needed:
taskkill /PID <process_id> /F
```

### Flutter can't connect
1. Check backend: http://localhost:8000/health
2. Check browser console (F12) for errors
3. Make sure CORS is enabled (already done)

### Docker issues
1. Make sure Docker Desktop is running
2. Check Docker icon in system tray
3. Restart Docker Desktop if needed

### Database errors
```bash
# Reset database
cd backend
del edtech_scanner.db
python run_dev.py
```

---

Need more help? Check `SETUP_GUIDE.md` for detailed explanations! 📚
