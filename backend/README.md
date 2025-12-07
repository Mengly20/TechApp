# EdTech Scanner Backend API

FastAPI backend for the EdTech Science Equipment Scanner application with PostgreSQL, Redis, and AI integration.

## Features

- **Authentication**: Google OAuth, Phone OTP, JWT tokens
- **Equipment Database**: PostgreSQL with sample science equipment
- **AI Image Recognition**: TensorFlow Lite model integration
- **AI Chat Assistant**: Google Gemini API integration
- **Caching**: Redis for OTP storage and token blacklisting
- **RESTful API**: Complete REST API with OpenAPI documentation

## Technology Stack

- **Framework**: FastAPI 0.104+
- **Database**: PostgreSQL 14+
- **Cache**: Redis 7+
- **ML/AI**: TensorFlow Lite, Google Gemini
- **Authentication**: JWT, Google OAuth, Twilio (SMS)
- **Containerization**: Docker & Docker Compose

## Quick Start

### Using Docker Compose (Recommended)

1. **Clone and navigate to backend directory**
```bash
cd backend
```

2. **Create environment file**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start all services**
```bash
docker-compose up -d
```

4. **Access the API**
- API: http://localhost:8000
- Documentation: http://localhost:8000/docs
- PostgreSQL: localhost:5432
- Redis: localhost:6379

5. **View logs**
```bash
docker-compose logs -f api
```

### Manual Setup

1. **Install dependencies**
```bash
pip install -r requirements.txt
```

2. **Set up PostgreSQL**
```bash
# Install PostgreSQL 14+
createdb edtech_scanner
psql edtech_scanner < init_db.sql
```

3. **Set up Redis**
```bash
# Install Redis 7+
redis-server
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your settings
```

5. **Run the server**
```bash
uvicorn app.main:app --reload --port 8000
```

## API Endpoints

### Authentication
- `POST /api/auth/google-signin` - Sign in with Google
- `POST /api/auth/send-otp` - Send OTP to phone
- `POST /api/auth/verify-otp` - Verify OTP and sign in
- `POST /api/auth/signout` - Sign out and blacklist token

### Equipment
- `GET /api/equipment/list` - List all equipment
- `GET /api/equipment/{id}` - Get equipment details
- `GET /api/equipment/categories` - Get categories
- `POST /api/equipment` - Create equipment (admin)

### Scanning
- `POST /api/scan/analyze` - Analyze equipment image
- `POST /api/scan/chat` - Chat with AI about equipment
- `POST /api/scan/sync` - Sync scan metadata
- `GET /api/scan/history` - Get scan history

### System
- `GET /health` - Health check
- `GET /` - API information

## Database Schema

### Users Table
```sql
- user_id (UUID, PK)
- auth_method (ENUM: google, phone, guest)
- google_id, phone_number, email
- full_name, profile_picture
- language_preference
- is_active, created_at, updated_at
- last_login_at, deleted_at
```

### Equipment Table
```sql
- equipment_id (UUID, PK)
- class_name (unique)
- name_en, name_km
- category, description_en, description_km
- usage_en, usage_km
- safety_info_en, safety_info_km
- image_url, tags[]
- created_at, updated_at
```

### Scan Metadata Table
```sql
- scan_id (UUID, PK)
- user_id (FK to users)
- equipment_id (FK to equipment)
- confidence_score
- device_info (JSON)
- scanned_at, synced_at
```

## ML Model Integration

### TensorFlow Lite Model
Place your trained model in `models/` directory:
- `model.tflite` - TFLite model file
- `labels.txt` - Class labels (one per line)
- `model_config.json` - Model configuration

### Google Gemini API
Set your API key in `.env`:
```
GEMINI_API_KEY=your-key-here
```

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/edtech_scanner

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret

# Twilio (SMS/OTP)
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=your-phone-number

# Google Gemini
GEMINI_API_KEY=your-gemini-key

# App
ENVIRONMENT=development
DEBUG=True
ALLOWED_ORIGINS=http://localhost:8080,http://localhost:3000
```

## Development

### Run tests
```bash
pytest
```

### Format code
```bash
black app/
```

### Database migrations
```bash
alembic revision --autogenerate -m "migration message"
alembic upgrade head
```

## Production Deployment

1. **Update environment variables**
   - Set `ENVIRONMENT=production`
   - Set `DEBUG=False`
   - Use strong `SECRET_KEY`
   - Configure real OAuth credentials
   - Set up SSL/TLS

2. **Use production database**
   - Configure PostgreSQL with SSL
   - Set up database backups
   - Configure connection pooling

3. **Deploy with Docker**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

4. **Set up reverse proxy (Nginx)**
   - Configure SSL certificates
   - Set up rate limiting
   - Configure caching

## API Documentation

Interactive API documentation is available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Support

For issues and questions, please refer to the main project documentation.

## License

MIT License
