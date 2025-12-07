================================================================================
EDTECH SCIENCE EQUIPMENT SCANNER - SPECIFICATION DRIVE DOCUMENT
================================================================================

PROJECT OVERVIEW
================================================================================
Project Name: EdTech Science Equipment Scanner
Version: 1.0.0
Document Type: Specification Drive (Complete Development Blueprint)
Last Updated: November 29, 2025

PURPOSE:
This specification drive document provides a complete blueprint for developing
a cross-platform mobile application that scans and identifies science laboratory
equipment using AI-powered image recognition and provides intelligent assistance
through conversational AI.

TECHNOLOGY STACK:
- Frontend: Flutter 3.16+ (iOS, Android, Web, Desktop)
- Backend: FastAPI (Python 3.11+)
- Database: PostgreSQL 14+
- Cache/Session: Redis 7+
- Authentication: Google OAuth 2.0, Phone OTP (Firebase Auth/Twilio)
- Local Storage: SQLite, FlutterSecureStorage
- AI Services: 
  * Custom TensorFlow Lite Model (model.tflite) - Image Recognition
  * Google Gemini API - Chatbot
- ML Framework: TensorFlow Lite (Python & Flutter)
- Image Processing: Pillow (Python), image_picker (Flutter)

TARGET PLATFORMS:
- Android 8.0+
- iOS 13.0+
- Web (Chrome, Safari, Firefox)
- Desktop (macOS, Windows, Linux) - Optional Phase 2


================================================================================
SECTION 1: SYSTEM ARCHITECTURE
================================================================================

1.1 HIGH-LEVEL ARCHITECTURE
--------------------------------------------------------------------------------

┌─────────────────────────────────────────────────────────────────────────┐
│                           MOBILE APPLICATION (FLUTTER)                   │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌──────────────────┐   │
│  │   Home    │  │   Scan    │  │  History  │  │  Authentication  │   │
│  │  Screen   │  │  Screen   │  │  Screen   │  │     Screens      │   │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └────────┬─────────┘   │
│        │              │              │                  │               │
│  ┌─────┴──────────────┴──────────────┴──────────────────┴─────────┐   │
│  │                      STATE MANAGEMENT (PROVIDER)                │   │
│  │    AuthProvider | ScanProvider | HistoryProvider | AppState    │   │
│  └─────┬──────────────────────────────────────────────────────────┘   │
│        │                                                                │
│  ┌─────┴──────────────────────────────────────────────────────────┐   │
│  │                         SERVICE LAYER                           │   │
│  │  AuthService | ScanService | EquipmentService | StorageService │   │
│  └─────┬──────────────────────────────────────────────────────────┘   │
│        │                                                                │
│  ┌─────┴─────────────────────────┬─────────────────────────────────┐  │
│  │      API CLIENT (Dio)         │   LOCAL STORAGE (SQLite)        │  │
│  └───────────┬───────────────────┴─────────────────────────────────┘  │
└──────────────┼────────────────────────────────────────────────────────┘
               │
               │ HTTPS/REST API
               │
┌──────────────┴────────────────────────────────────────────────────────┐
│                      BACKEND API (FASTAPI)                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │     Auth     │  │   Scanning   │  │   Equipment  │                │
│  │  Endpoints   │  │  Endpoints   │  │  Endpoints   │                │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                │
│         │                  │                  │                        │
│  ┌──────┴──────────────────┴──────────────────┴─────────────────┐    │
│  │                    BUSINESS LOGIC LAYER                       │    │
│  │   JWT Auth | Image Processing | AI Integration | Data Mgmt   │    │
│  └──────┬──────────────────────────┬─────────────────────────────┘    │
│         │                          │                                   │
│  ┌──────┴────────┐        ┌────────┴────────┐                         │
│  │  PostgreSQL   │        │   Redis Cache   │                         │
│  │   Database    │        │  (OTP/Sessions) │                         │
│  └───────────────┘        └─────────────────┘                         │
└───────────────────────────────┬───────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────┴────────┐      ┌──────┴──────┐
            │  TFLite Model  │      │ Gemini API  │
            │ (model.tflite) │      │  (Chatbot)  │
            │ Image Recognition│    │             │
            └────────────────┘      └─────────────┘


1.2 DATA FLOW ARCHITECTURE
--------------------------------------------------------------------------------

USER AUTHENTICATION FLOW:
┌──────┐     ┌─────────┐     ┌─────────┐     ┌────────────┐
│ User │────▶│ Flutter │────▶│ FastAPI │────▶│ PostgreSQL │
│      │◀────│   App   │◀────│  Server │◀────│  Database  │
└──────┘     └────┬────┘     └────┬────┘     └────────────┘
                  │               │
                  │               ├─────▶ Google OAuth API
                  │               │
                  │               └─────▶ Firebase Auth/Twilio (OTP)
                  │
                  └─────▶ FlutterSecureStorage (JWT Token)

SCAN EQUIPMENT FLOW:
┌──────┐     ┌─────────┐     ┌─────────┐     ┌──────────────────┐
│ User │────▶│ Flutter │────▶│ FastAPI │────▶│ TFLite Model     │
│      │     │   App   │     │  Server │     │ (model.tflite)   │
└──────┘     └────┬────┘     └────┬────┘     └──────────────────┘
                  │               │
                  │               ├─────▶ PostgreSQL (Equipment DB)
                  │               │
                  │               └─────▶ Gemini API (Chat)
                  │
                  └─────▶ Local SQLite (Save History)

LOCAL VS CLOUD STORAGE:
┌──────────────────────────┐         ┌────────────────────────────┐
│   LOCAL DEVICE STORAGE   │         │    CLOUD/BACKEND STORAGE   │
├──────────────────────────┤         ├────────────────────────────┤
│ ✓ Scan Images (Full)     │         │ ✓ User Profiles            │
│ ✓ Scan Thumbnails        │         │ ✓ Equipment Database       │
│ ✓ Scan History Metadata  │         │ ✓ AI Model Configurations  │
│ ✓ User Notes             │         │ ✓ Scan Metadata (Analytics)│
│ ✓ JWT Tokens             │         │ ✓ API Keys (Encrypted)     │
│ ✓ App Preferences        │         │                            │
└──────────────────────────┘         └────────────────────────────┘

Guest Users: LOCAL ONLY
Authenticated Users: LOCAL + CLOUD SYNC (Metadata Only)


1.3 SECURITY ARCHITECTURE
--------------------------------------------------------------------------------

AUTHENTICATION SECURITY:
┌─────────────────────────────────────────────────────────────────┐
│ Frontend (Flutter)                                               │
│ ├─ FlutterSecureStorage (Encrypted Keychain/Keystore)          │
│ │  └─ JWT Token (24-hour expiry)                               │
│ ├─ Google Sign-In Package (OAuth 2.0)                          │
│ └─ Firebase Auth (Phone OTP)                                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓ HTTPS Only
┌─────────────────────────────────────────────────────────────────┐
│ Backend (FastAPI)                                                │
│ ├─ JWT Token Validation (Every Protected Request)              │
│ ├─ Token Blacklist (Redis - For Logout)                        │
│ ├─ OTP Storage (Redis - 5 min TTL)                             │
│ ├─ Rate Limiting (100 req/min per user)                        │
│ └─ API Key Encryption (AES-256)                                │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Database (PostgreSQL)                                            │
│ ├─ Encrypted at Rest                                            │
│ ├─ SSL/TLS Connections                                          │
│ ├─ Parameterized Queries (SQL Injection Prevention)            │
│ └─ Row-Level Security (RLS)                                     │
└─────────────────────────────────────────────────────────────────┘

DATA PRIVACY:
- Guest users: Data stays on device only
- Authenticated users: Images stay local, only metadata synced
- No PII shared with AI services
- GDPR compliant (Right to delete, Right to export)

================================================================================
SECTION 2: FEATURE SPECIFICATIONS
================================================================================

2.0 TFLITE MODEL INTEGRATION
--------------------------------------------------------------------------------

FEATURE: Custom TensorFlow Lite Model for Equipment Recognition
PRIORITY: Critical (P0)
USER STORY: As a developer, I need to integrate a custom TFLite model for offline-capable equipment recognition

MODEL SPECIFICATIONS:
---------------------
Model File: model.tflite
Model Type: Image Classification / Object Detection
Input Format: 
  - Image tensor
  - Shape: [1, 224, 224, 3] (Batch, Height, Width, Channels)
  - Data type: float32
  - Value range: [0.0, 1.0] (normalized)

Output Format:
  - Prediction tensor
  - Shape: [1, NUM_CLASSES]
  - Data type: float32
  - Values: Confidence scores (0.0 to 1.0)

Supported Classes: (Example - Update based on your model)
  0: microscope
  1: beaker
  2: test-tube
  3: flask
  4: bunsen-burner
  5: thermometer
  6: pipette
  7: petri-dish
  8: graduated-cylinder
  9: stirring-rod
  10: funnel
  ... (add all your classes)

MODEL DEPLOYMENT ARCHITECTURE:
┌────────────────────────────────────────────────────────────────────┐
│                    BACKEND (FastAPI) - PRIMARY INFERENCE           │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  /models/                                                     │ │
│  │    ├── model.tflite (Primary model)                          │ │
│  │    ├── labels.txt (Class labels)                             │ │
│  │    └── model_config.json (Model metadata)                    │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  Model Loading:                                                    │
│  - Load at app startup (singleton pattern)                        │
│  - Keep model in memory for fast inference                        │
│  - Thread-safe inference queue                                    │
│                                                                     │
│  Preprocessing Pipeline:                                           │
│  - Resize image to model input size                               │
│  - Convert to RGB if needed                                        │
│  - Normalize pixel values                                          │
│  - Convert to float32 numpy array                                  │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│              FRONTEND (Flutter) - OPTIONAL OFFLINE MODE            │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  assets/models/                                               │ │
│  │    ├── model.tflite (Copy of model for offline use)          │ │
│  │    └── labels.txt                                             │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  Use Case: Offline scanning when no internet connection           │
│  Package: tflite_flutter                                           │
│  Note: Optional Phase 2 feature                                    │
└────────────────────────────────────────────────────────────────────┘

BACKEND IMPLEMENTATION DETAILS:
--------------------------------

File Structure:
backend/
├── app/
│   ├── main.py
│   ├── api/
│   │   ├── auth.py
│   │   ├── scan.py
│   │   └── equipment.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── tflite_inference.py  ← New: TFLite wrapper
│   │   └── model_manager.py      ← New: Model lifecycle
│   ├── core/
│   │   ├── config.py
│   │   └── database.py
│   └── schemas/
│       ├── user.py
│       └── scan.py
├── models/                         ← New: Model files directory
│   ├── model.tflite               ← Your trained model
│   ├── labels.txt                 ← Class labels (one per line)
│   └── model_config.json          ← Model metadata
├── requirements.txt
└── README.md

Model Config File (models/model_config.json):
{
  "model_name": "science_equipment_classifier_v1",
  "model_version": "1.0.0",
  "model_type": "classification",
  "input_shape": [1, 224, 224, 3],
  "input_dtype": "float32",
  "output_shape": [1, 20],
  "output_dtype": "float32",
  "num_classes": 20,
  "preprocessing": {
    "resize": [224, 224],
    "normalize": true,
    "mean": [0.485, 0.456, 0.406],
    "std": [0.229, 0.224, 0.225]
  },
  "postprocessing": {
    "confidence_threshold": 0.5,
    "top_k": 3
  },
  "metadata": {
    "trained_on": "2025-01-15",
    "framework": "TensorFlow 2.15",
    "accuracy": 0.94,
    "description": "Science equipment classifier trained on 10,000 images"
  }
}

Class Labels File (models/labels.txt):
microscope
beaker
test-tube
flask
bunsen-burner
thermometer
pipette
petri-dish
graduated-cylinder
stirring-rod
funnel
erlenmeyer-flask
volumetric-flask
watch-glass
crucible
tripod
wire-gauze
test-tube-rack
test-tube-holder
dropper

2.1 AUTHENTICATION SYSTEM
--------------------------------------------------------------------------------

FEATURE: User Authentication
PRIORITY: Critical (P0)
USER STORY: As a user, I want to sign in to save my scan history across devices

AUTHENTICATION METHODS:
1. Guest Mode (No Authentication)
2. Google OAuth 2.0
3. Phone Number + OTP

┌────────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION STATE MACHINE                     │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [App Launch] ──┬──▶ JWT Exists? ──Yes──▶ Validate ──Valid──▶ [Home]
│                 │                            │                      │
│                 │                            │                      │
│                 No                        Invalid                   │
│                 │                            │                      │
│                 ▼                            ▼                      │
│           [Welcome Screen] ◀─────────────────┘                     │
│                 │                                                   │
│         ┌───────┼───────┐                                          │
│         │       │       │                                          │
│      [Guest] [Google] [Phone]                                      │
│         │       │       │                                          │
│         │       │       └──▶ [Enter Phone] ──▶ [OTP] ──┐          │
│         │       │                                       │          │
│         │       └──▶ [Google OAuth Flow] ──────────────┤          │
│         │                                               │          │
│         └──▶ [Limited Access] ──────────────────────────┤          │
│                                                          │          │
│                                                          ▼          │
│                                                      [Home Screen]  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘

WORKFLOW: GUEST MODE
--------------------
Step 1: User opens app
Step 2: User taps "Continue as Guest"
Step 3: App creates temporary session ID (UUID)
Step 4: Navigate to Home Screen
Step 5: Bottom nav shows: Home ✓ | Scan ✓ | History ✗ (locked)

RESTRICTIONS:
- Cannot access History screen
- Cannot sync data
- Data deleted if app uninstalled
- No cloud backup

WORKFLOW: GOOGLE SIGN-IN
-------------------------
Step 1: User taps "Sign in with Google"
Step 2: Flutter calls GoogleSignIn.signIn()
Step 3: Google OAuth consent screen shown
Step 4: User grants permission
Step 5: Google returns ID token
Step 6: Flutter sends to backend:
        POST /api/auth/google-signin
        Body: { "id_token": "xxx", "device_info": {...} }
Step 7: Backend validates token with Google API
Step 8: Backend queries: SELECT * FROM users WHERE google_id = ?
Step 9: If user exists:
        - Update last_login_at
        - Generate new JWT
        If new user:
        - INSERT INTO users (google_id, email, full_name, ...)
        - Generate JWT
Step 10: Backend returns:
         { "access_token": "jwt_xxx", "user": {...} }
Step 11: Flutter stores JWT in FlutterSecureStorage
Step 12: Navigate to Home Screen (full access)

WORKFLOW: PHONE OTP SIGN-IN
----------------------------
Step 1: User taps "Sign in with Phone Number"
Step 2: User enters phone number (+855123456789)
Step 3: Flutter validates format (E.164)
Step 4: Flutter sends:
        POST /api/auth/send-otp
        Body: { "phone_number": "+855123456789", "country_code": "KH" }
Step 5: Backend generates 6-digit OTP (random.randint(100000, 999999))
Step 6: Backend stores in Redis:
        redis.setex(f"otp:{phone_number}", 300, otp_code)
Step 7: Backend sends SMS via Firebase Auth or Twilio
Step 8: User receives SMS: "Your OTP is: 123456"
Step 9: User enters OTP in app (6 input boxes)
Step 10: Flutter sends:
         POST /api/auth/verify-otp
         Body: { "phone_number": "+855123456789", "otp_code": "123456" }
Step 11: Backend retrieves: redis.get(f"otp:{phone_number}")
Step 12: Backend compares OTP
Step 13: If match:
         - Delete OTP from Redis
         - Query/create user in PostgreSQL
         - Generate JWT
         - Return { "access_token": "jwt_xxx", "user": {...} }
         If no match:
         - Return { "error": "Invalid OTP" }
         - Allow 3 retries, then block for 10 min
Step 14: Flutter stores JWT and navigates to Home

WORKFLOW: SIGN OUT
------------------
Step 1: User taps profile icon → "Sign Out"
Step 2: Flutter shows confirmation dialog
Step 3: If confirmed:
        - Call POST /api/auth/signout (with JWT header)
        - Backend adds JWT to Redis blacklist
        - Delete JWT from FlutterSecureStorage
        - Clear all cached user data
        - Navigate to Welcome Screen
Step 4: Local scan history remains on device


2.2 SCANNING SYSTEM
--------------------------------------------------------------------------------

FEATURE: Equipment Scanning with AI Recognition
PRIORITY: Critical (P0)
USER STORY: As a user, I want to identify science equipment by taking a photo

SCANNING WORKFLOW:
┌────────────────────────────────────────────────────────────────────┐
│                        SCAN PROCESS FLOW                            │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [Scan Screen]                                                      │
│       │                                                             │
│       ├──▶ Request Camera Permission ──No──▶ [Show Error]         │
│       │           │                                                 │
│       │          Yes                                                │
│       │           │                                                 │
│       ▼           ▼                                                 │
│  [Camera Preview]                                                   │
│       │                                                             │
│       ├──▶ User Taps Capture ──▶ [Take Photo]                     │
│       │                              │                              │
│       └──▶ User Taps Gallery ──▶ [Pick Image]                     │
│                                      │                              │
│                                      ▼                              │
│                              [Image Captured]                       │
│                                      │                              │
│                                      ├──▶ Show Preview              │
│                                      │                              │
│                                      ├──▶ Validate Image            │
│                                      │    (Format, Size < 10MB)    │
│                                      │                              │
│                                      ▼                              │
│                           [Upload to Backend]                       │
│                                      │                              │
│                                      ├──▶ Show Loading Spinner      │
│                                      │    "Analyzing with AI..."    │
│                                      │                              │
│                   ┌──────────────────┴──────────────────┐          │
│                   │                                      │          │
│              [Backend]                                   │          │
│                   │                                      │          │
│                   ├──▶ TFLite Model (model.tflite)  │  │
                              │                                              │        
│                   │    (Image Recognition)              │          │
│                   │         │                            │          │
│                   │         ├──▶ Parse Predictions       │          │
│                   │         │    (class, confidence, bbox)│         │
│                   │         │                            │          │
│                   │         ├──▶ Query Equipment DB      │          │
│                   │         │    (Get full details)      │          │
│                   │         │                            │          │
│                   │         └──▶ Return Enriched Data    │          │
│                   │                                      │          │
│                   └──────────────────┬──────────────────┘          │
│                                      │                              │
│                                      ▼                              │
│                              [Display Results]                      │
│                                      │                              │
│                   ┌──────────────────┼──────────────────┐          │
│                   │                  │                  │          │
│              [Save Scan]      [Chat with AI]      [Retake]         │
│                   │                  │                  │          │
│                   ▼                  ▼                  ▼          │
│           [Local Storage]    [AI Chat Dialog]   [Back to Camera]  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘

DETAILED STEPS: IMAGE CAPTURE
------------------------------
Step 1: User navigates to Scan Screen
Step 2: Check camera permission:
        - Android: camera permission
        - iOS: camera & photo library permissions
Step 3: If not granted, show permission dialog
Step 4: If denied, show error + settings button
Step 5: If granted, initialize camera:
        - Use image_picker package
        - Show camera preview (full screen)
        - Display capture button (center bottom)
        - Display gallery button (bottom left)
        - Display flash toggle (top right)

Step 6: User captures photo OR selects from gallery
Step 7: Read image file: File imageFile = File(pickedFile.path)
Step 8: Validate image:
        - Check format: jpg, png, heic
        - Check size: < 10MB
        - If invalid, show error and return to camera
Step 9: Show preview of captured image
Step 10: Display "Analyze" button

DETAILED STEPS: IMAGE ANALYSIS
-------------------------------
Step 1: User taps "Analyze" button
Step 2: Show loading overlay: "Analyzing with AI..."
Step 3: Read image as bytes: Uint8List imageBytes = await imageFile.readAsBytes()
Step 4: Create multipart request:
        - endpoint: POST /api/scan/analyze
        - headers: Authorization: Bearer {jwt} (if authenticated)
        - body: multipart/form-data
          * image: binary image data
          * user_id: uuid or null

Step 5: Backend receives image
Step 6: Backend validates image (size, format)
Step 7: Backend encodes to base64:
        import base64
        image_base64 = base64.b64encode(image_bytes).decode('utf-8')
Step 8: Backend calls TFLite Model for inference
Step 9: Backend parses TFLite model output
Step 10: Backend extracts top prediction (highest confidence)
Step 11: Backend queries equipment database

Step 12: Backend enriches response

Step 13: Backend returns enriched data (200 OK)
Step 14: If authenticated, backend logs to scan_metadata table
Step 15: Frontend receives response
Step 16: Hide loading spinner
Step 17: Display results card

DETAILED STEPS: SAVE SCAN
--------------------------
Step 1: User taps "Save Scan" button
Step 2: Generate scan ID
Step 3: Create local file paths
Step 4: Save full image to app documents directory
Step 5: Generate thumbnail (200x200)
Step 6: Create scan record object
Step 7: Insert into local SQLite database
Step 8: Show success snackbar
Step 9: If user authenticated, sync metadata to backend
Step 10: If sync successful, update local record

2.3 AI CHAT SYSTEM
--------------------------------------------------------------------------------

FEATURE: AI-Powered Equipment Assistant
PRIORITY: High (P1)
USER STORY: As a user, I want to ask questions about identified equipment

CHAT WORKFLOW:
┌────────────────────────────────────────────────────────────────────┐
│                         AI CHAT FLOW                                │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [Scan Results] ──▶ User Taps "Chat with AI"                      │
│                            │                                        │
│                            ▼                                        │
│                    [Open Chat Dialog]                              │
│                            │                                        │
│                            ├──▶ Display Equipment Context           │
│                            │    "I identified: Microscope"          │
│                            │                                        │
│                            ├──▶ Show Suggested Questions            │
│                            │    • How do I use this?                │
│                            │    • What safety precautions?          │
│                            │    • How to maintain it?               │
│                            │                                        │
│                            ▼                                        │
│                    [User Enters Question]                          │
│                            │                                        │
│                            ├──▶ "How do I adjust focus?"           │
│                            │                                        │
│                            ▼                                        │
│                    [Send to Backend]                               │
│                            │                                        │
│                   POST /api/scan/chat                              │
│                   Body: {                                          │
│                     "equipment_id": "uuid",                        │
│                     "equipment_name": "Microscope",                │
│                     "user_message": "How do I adjust focus?",      │
│                     "conversation_history": [...]                  │
│                   }                                                │
│                            │                                        │
│                            ▼                                        │
│              [Backend Processes Request]                           │
│                            │                                        │
│                            ├──▶ Build Context Prompt                │
│                            │    "You are a science equipment expert"│
│                            │    "Equipment: Compound Microscope"    │
│                            │    "Usage: ..."                        │
│                            │    "User asks: How to adjust focus?"   │
│                            │                                        │
│                            ├──▶ Call Gemini API                     │
│                            │    model.generate_content(prompt)      │
│                            │                                        │
│                            ├──▶ Receive AI Response                 │
│                            │                                        │
│                            ▼                                        │
│              [Return AI Response to Frontend]                      │
│                            │                                        │
│                            ▼                                        │
│                    [Display AI Message]                            │
│                            │                                        │
│                    "To adjust focus on a compound                  │
│                     microscope, first use the coarse               │
│                     adjustment knob to get a rough                 │
│                     focus, then fine-tune with the                 │
│                     fine adjustment knob..."                       │
│                            │                                        │
│                            ▼                                        │
│                    [User Can Ask More]                             │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘

DETAILED STEPS: AI CHAT
------------------------
Step 1: User taps "Chat with AI" button on scan results
Step 2: Flutter opens bottom sheet dialog (full screen modal)
Step 3: Display chat header
Step 4: Initialize conversation with equipment context
Step 5: Display suggested questions (chips):
        - "How do I use this?"
        - "What are safety precautions?"
        - "How to clean and maintain?"
        - "What are common mistakes?"
Step 6: User types question OR taps suggested question
Step 7: Add user message to chat UI
Step 8: Show "AI is typing..." indicator
Step 9: Send request to backend
Step 10: Backend receives request
Step 11: Backend builds Gemini prompt
Step 12: Backend calls Gemini API:gemini-2.5-flash-exp
Step 13: Backend extracts AI response text
Step 14: Backend returns response
Step 15: Frontend receives response
Step 16: Hide "typing" indicator
Step 17: Add AI message to chat UI

================================================================================
SECTION 3: MACHINE LEARNING MODEL MANAGEMENT
================================================================================

3.1 TFLITE MODEL TRAINING PIPELINE
--------------------------------------------------------------------------------

OVERVIEW:
The custom TFLite model must be trained on science equipment images before
deployment. This section outlines the complete training and conversion process.

TRAINING DATA REQUIREMENTS:
---------------------------
Dataset Structure:
dataset/
├── train/
│   ├── microscope/
│   │   ├── img001.jpg
│   │   ├── img002.jpg
│   │   └── ... (minimum 100 images per class)
│   ├── beaker/
│   ├── test-tube/
│   ├── flask/
│   └── ... (all equipment classes)
├── validation/
│   ├── microscope/
│   ├── beaker/
│   └── ...
└── test/
    ├── microscope/
    ├── beaker/
    └── ...
TRAINING PROCESS:
================================================================================
SECTION 4: COMPLETE BACKEND API REFERENCE
================================================================================
4.1 API OVERVIEW
--------------------------------------------------------------------------------

BASE URL: https://api.edtech-scanner.com/api/v1
PROTOCOL: HTTPS only
AUTHENTICATION: JWT Bearer Token (where required)
CONTENT TYPE: application/json (except file uploads)
RESPONSE FORMAT: JSON
STANDARD RESPONSE STRUCTURE

4.2 AUTHENTICATION ENDPOINTS
--------------------------------------------------------------------------------

4.2.1 POST /api/auth/google-signin
-----------------------------------
DESCRIPTION: Authenticate user with Google OAuth ID token
AUTHENTICATION: Not required
RATE LIMIT: 10 requests per minute

ERROR CODES:
- INVALID_TOKEN: Google ID token is invalid or expired
- TOKEN_VERIFICATION_FAILED: Unable to verify token with Google
- MISSING_REQUIRED_FIELDS: Required fields missing in request
- ACCOUNT_DISABLED: User account has been disabled

BACKEND LOGIC:
1. Validate request body (id_token required)
2. Verify Google ID token with Google API
3. Extract user info (email, name, picture, google_id)
4. Query database: SELECT * FROM users WHERE google_id = ?
5. If user exists:
   - UPDATE users SET last_login_at = NOW() WHERE user_id = ?
6. If new user:
   - INSERT INTO users (user_id, auth_method, google_id, email, ...)
7. Generate JWT token (24-hour expiry)
8. Return user data + JWT token


4.2.2 POST /api/auth/send-otp
------------------------------
DESCRIPTION: Send OTP code to phone number for authentication
AUTHENTICATION: Not required
RATE LIMIT: 3 requests per hour per phone number
ERROR CODES:
- INVALID_PHONE_NUMBER: Phone number format invalid
- RATE_LIMIT_EXCEEDED: Too many OTP requests
- SMS_SEND_FAILED: Failed to send SMS
- UNSUPPORTED_COUNTRY: Country code not supported
BACKEND LOGIC:
1. Validate phone number format (E.164)
2. Check rate limit (max 3 per hour)
3. Generate 6-digit OTP: random.randint(100000, 999999)
4. Store in Redis: redis.setex(f"otp:{phone_number}", 300, otp_code)
5. Send SMS via Firebase Auth or Twilio
6. Return success response


4.2.3 POST /api/auth/verify-otp
--------------------------------
DESCRIPTION: Verify OTP code and authenticate user
AUTHENTICATION: Not required
RATE LIMIT: 10 requests per minute
ERROR CODES:
- INVALID_OTP: OTP code is incorrect
- OTP_EXPIRED: OTP has expired (5 minutes)
- OTP_NOT_FOUND: No OTP found for this phone number
- MAX_ATTEMPTS_EXCEEDED: Too many failed attempts (3 max)
- MISSING_REQUIRED_FIELDS: Required fields missing

BACKEND LOGIC:
1. Validate request body
2. Retrieve OTP from Redis: redis.get(f"otp:{phone_number}")
3. Check if OTP exists and not expired
4. Compare OTP codes
5. Track failed attempts (max 3)
6. If valid:
   - Delete OTP from Redis
   - Query/create user in database
   - Generate JWT token
   - Return user + token
7. If invalid:
   - Increment failed attempts counter
   - Return error with remaining attempts


4.2.4 POST /api/auth/signout
-----------------------------
DESCRIPTION: Sign out user and invalidate JWT token
AUTHENTICATION: Required
RATE LIMIT: 10 requests per minute
ERROR CODES:
- INVALID_TOKEN: JWT token is invalid
- TOKEN_EXPIRED: JWT token has expired
- UNAUTHORIZED: No token provided

BACKEND LOGIC:
1. Validate JWT token
2. Extract token from Authorization header
3. Add token to blacklist: redis.setex(f"blacklist:{token}", 86400, "1")
4. Return success response


4.2.5 POST /api/auth/refresh-token
-----------------------------------
DESCRIPTION: Refresh expired JWT token (Optional - Phase 2)
AUTHENTICATION: Required (refresh token)
RATE LIMIT: 10 requests per minute

4.3 USER PROFILE ENDPOINTS
--------------------------------------------------------------------------------

4.3.1 GET /api/users/profile
-----------------------------
DESCRIPTION: Get current user profile and statistics
AUTHENTICATION: Required
RATE LIMIT: 50 requests per minute

ERROR CODES:
- UNAUTHORIZED: Invalid or missing token
- USER_NOT_FOUND: User no longer exists

BACKEND LOGIC:
1. Validate JWT token
2. Extract user_id from token
3. Query user: SELECT * FROM users WHERE user_id = ?
4. Query scan stats:
   SELECT COUNT(*) as total_scans,
          COUNT(DISTINCT equipment_id) as unique_equipment,
          MAX(scanned_at) as last_scan_date
   FROM scan_metadata
   WHERE user_id = ?
5. Query most scanned equipment:
   SELECT equipment_id, COUNT(*) as count
   FROM scan_metadata
   WHERE user_id = ?
   GROUP BY equipment_id
   ORDER BY count DESC
   LIMIT 1
6. Return user profile + stats
4.3.2 PUT /api/users/profile
-----------------------------
DESCRIPTION: Update user profile information
AUTHENTICATION: Required
RATE LIMIT: 10 requests per minute

ALLOWED FIELDS:
- full_name (string, max 255 chars)
- language_preference (enum: 'en', 'km')
- profile_picture (string, URL)

ERROR CODES:
- VALIDATION_ERROR: Invalid field values
- UNAUTHORIZED: Invalid token
- FIELD_NOT_ALLOWED: Trying to update protected fields


4.3.3 DELETE /api/users/profile
--------------------------------
DESCRIPTION: Delete user account and all associated data
AUTHENTICATION: Required
RATE LIMIT: 1 request per day


BACKEND LOGIC:
1. Validate confirmation text
2. Soft delete user: UPDATE users SET is_active = FALSE, deleted_at = NOW()
3. Delete all scan_metadata: DELETE FROM scan_metadata WHERE user_id = ?
4. Blacklist current token
5. Return success response

NOTE: User's local scan history remains on their device


4.4 EQUIPMENT ENDPOINTS
--------------------------------------------------------------------------------

4.4.1 GET /api/equipment/list
------------------------------
DESCRIPTION: Get list of all equipment with optional filters
AUTHENTICATION: Optional (public endpoint)
RATE LIMIT: 50 requests per minute
QUERY PARAMETERS:
- category (optional): Filter by category name
- search (optional): Search in equipment name (English or Khmer)
- language (optional): Response language ('en' or 'km'), default 'en'
- limit (optional): Number of results per page, default 50, max 100
- offset (optional): Pagination offset, default 0
- tags (optional): Comma-separated tags for filtering
BACKEND LOGIC:
1. Parse query parameters
2. Build SQL query with filters
3. Apply language-specific name selection
4. Execute query with pagination
5. Return equipment list


4.4.2 GET /api/equipment/{equipment_id}
----------------------------------------
DESCRIPTION: Get detailed information about specific equipment
AUTHENTICATION: Optional
RATE LIMIT: 50 requests per minute

4.4.3 GET /api/equipment/categories
------------------------------------
DESCRIPTION: Get list of all equipment categories
AUTHENTICATION: Optional
RATE LIMIT: 50 requests per minute

4.5 SCANNING ENDPOINTS
--------------------------------------------------------------------------------

4.5.1 POST /api/scan/analyze
-----------------------------
DESCRIPTION: Analyze equipment image using TFLite model
AUTHENTICATION: Optional (guest users can scan without auth)
RATE LIMIT: 10 requests per minute (per user or IP)
MAX FILE SIZE: 10MB

ERROR CODES:
- INVALID_IMAGE: Image format not supported
- FILE_TOO_LARGE: Image exceeds 10MB limit
- MODEL_ERROR: TFLite model inference failed
- LOW_CONFIDENCE: Confidence below threshold (0.5)
- EQUIPMENT_NOT_IN_DATABASE: Class recognized but not in equipment DB

BACKEND LOGIC:
1. Validate image file (format, size)
2. Read image bytes
3. Load TFLite model (singleton)
4. Preprocess image (resize, normalize)
5. Run inference
6. Get predictions and confidence scores
7. If confidence >= 0.5:
   - Query equipment database
   - If authenticated: Log to scan_metadata table
   - Return enriched data
8. If confidence < 0.5:
   - Return low confidence error with suggestions


4.5.2 POST /api/scan/chat
--------------------------
DESCRIPTION: Chat with AI about identified equipment
AUTHENTICATION: Optional
RATE LIMIT: 20 requests per minute

ERROR CODES:
- EQUIPMENT_NOT_FOUND: Equipment ID not found
- AI_SERVICE_ERROR: Gemini API error
- MESSAGE_TOO_LONG: User message exceeds 1000 characters
- CONVERSATION_TOO_LONG: Conversation history too long

BACKEND LOGIC:
1. Validate request body
2. Query equipment details from database
3. Build context prompt with equipment info
4. Include conversation history
5. Call Google Gemini API
6. Return AI response


4.5.3 POST /api/scans/sync
---------------------------
DESCRIPTION: Sync scan metadata to cloud (for authenticated users)
AUTHENTICATION: Required
RATE LIMIT: 20 requests per minute


BACKEND LOGIC:
1. Validate JWT token
2. Extract user_id from token
3. INSERT INTO
<function_calls>
<invoke name="artifacts">
<parameter name="command">update</parameter>
<parameter name="id">edtech_spec</parameter>
<parameter name="new_str">BACKEND LOGIC:
1. Validate JWT token
2. Extract user_id from token
3. INSERT INTO scan_metadata (scan_id, user_id, equipment_id, 
   confidence_score, scanned_at, device_info, synced_at)
4. Return success response

NOTE: Image files are NOT uploaded, only metadata


4.5.4 GET /api/scans/history
-----------------------------
DESCRIPTION: Get user's scan history metadata from cloud (Optional - Phase 2)
AUTHENTICATION: Required
RATE LIMIT: 50 requests per minute
4.6 HEALTH & MONITORING ENDPOINTS
--------------------------------------------------------------------------------

4.6.1 GET /health
------------------
DESCRIPTION: Service health check
AUTHENTICATION: Not required
RATE LIMIT: None
4.6.2 GET /api/stats
---------------------
DESCRIPTION: Get system statistics (Admin only - Phase 2)
AUTHENTICATION: Required (Admin token)
RATE LIMIT: 10 requests per minute

4.7 ERROR HANDLING & STANDARD ERRORS
--------------------------------------------------------------------------------

COMMON ERROR CODES:

AUTHENTICATION ERRORS:
- UNAUTHORIZED: Missing or invalid authentication token
- TOKEN_EXPIRED: JWT token has expired
- TOKEN_BLACKLISTED: Token has been revoked
- INVALID_CREDENTIALS: Invalid username/password
- ACCOUNT_DISABLED: User account has been disabled
- SESSION_EXPIRED: User session has expired

VALIDATION ERRORS:
- VALIDATION_ERROR: Request validation failed
- MISSING_REQUIRED_FIELD: Required field not provided
- INVALID_FORMAT: Field value format is invalid
- INVALID_FILE_TYPE: File type not supported
- FILE_TOO_LARGE: File exceeds size limit
- INVALID_PARAMETER: Query parameter invalid

RESOURCE ERRORS:
- NOT_FOUND: Resource not found
- ALREADY_EXISTS: Resource already exists
- EQUIPMENT_NOT_FOUND: Equipment not found in database
- USER_NOT_FOUND: User not found

RATE LIMITING ERRORS:
- RATE_LIMIT_EXCEEDED: Too many requests
- QUOTA_EXCEEDED: User quota exceeded

SERVICE ERRORS:
- INTERNAL_SERVER_ERROR: Unexpected server error
- SERVICE_UNAVAILABLE: Service temporarily unavailable
- DATABASE_ERROR: Database operation failed
- MODEL_ERROR: ML model inference failed
- AI_SERVICE_ERROR: AI service (Gemini) error
- EXTERNAL_SERVICE_ERROR: External API error

BUSINESS LOGIC ERRORS:
- LOW_CONFIDENCE: ML model confidence too low
- INVALID_OPERATION: Operation not allowed
- INSUFFICIENT_PERMISSIONS: User lacks required permissions


4.8 WEBHOOKS & CALLBACKS (OPTIONAL - PHASE 2)
--------------------------------------------------------------------------------

4.8.1 POST /api/webhooks/scan-complete
---------------------------------------
DESCRIPTION: Webhook callback when scan analysis is complete (for async processing)
AUTHENTICATION: API Key
RATE LIMIT: None


================================================================================
SECTION 5: FRONTEND IMPLEMENTATION GUIDE
================================================================================

5.1 FLUTTER PROJECT STRUCTURE
--------------------------------------------------------------------------------

edtech_scanner_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # App widget with routing
│   │
│   ├── core/                              # Core functionality
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # API URLs, endpoints
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── storage_keys.dart          # Storage key names
│   │   ├── config/
│   │   │   ├── env_config.dart            # Environment configuration
│   │   │   └── theme_config.dart          # App theme settings
│   │   └── utils/
│   │       ├── date_formatter.dart        # Date formatting utilities
│   │       ├── validators.dart            # Input validators
│   │       └── image_helper.dart          # Image processing helpers
│   │
│   ├── data/                              # Data layer
│   │   ├── models/                        # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── equipment_model.dart
│   │   │   ├── scan_model.dart
│   │   │   └── chat_message_model.dart
│   │   ├── repositories/                  # Data repositories
│   │   │   ├── auth_repository.dart
│   │   │   ├── equipment_repository.dart
│   │   │   ├── scan_repository.dart
│   │   │   └── local_storage_repository.dart
│   │   └── data_sources/                  # Data sources
│   │       ├── remote/
│   │       │   ├── auth_api.dart
│   │       │   ├── equipment_api.dart
│   │       │   └── scan_api.dart
│   │       └── local/
│   │           ├── database_helper.dart   # SQLite helper
│   │           └── secure_storage.dart    # Secure storage
│   │
│   ├── services/                          # Business logic services
│   │   ├── api_client.dart                # HTTP client (Dio)
│   │   ├── auth_service.dart              # Authentication logic
│   │   ├── scan_service.dart              # Scanning logic
│   │   ├── equipment_service.dart         # Equipment data logic
│   │   ├── local_storage_service.dart     # Local storage logic
│   │   └── chat_service.dart              # AI chat logic
│   │
│   ├── providers/                         # State management (Provider)
│   │   ├── auth_provider.dart             # Auth state
│   │   ├── scan_provider.dart             # Scan state
│   │   ├── history_provider.dart          # History state
│   │   ├── language_provider.dart         # Language state
│   │   └── app_provider.dart              # Global app state
│   │
│   ├── screens/                           # UI screens
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── phone_signin_screen.dart
│   │   │   └── otp_verification_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── feature_card.dart
│   │   │       └── stats_card.dart
│   │   ├── scan/
│   │   │   ├── scan_screen.dart
│   │   │   ├── scan_result_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_view.dart
│   │   │       ├── result_card.dart
│   │   │       └── chat_dialog.dart
│   │   ├── history/
│   │   │   ├── history_screen.dart
│   │   │   ├── scan_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── scan_list_item.dart
│   │   │       └── empty_state.dart
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                           # Shared widgets
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   └── language_toggle.dart
│   │
│   └── l10n/                              # Localization
│       ├── app_en.json                    # English translations
│       └── app_km.json                    # Khmer translations
│
├── assets/                                # Assets
│   ├── images/
│   │   ├── logo.png
│   │   ├── welcome_bg.png
│   │   └── icons/
│   ├── fonts/
│   └── models/                            # Optional: TFLite for offline
│       └── model.tflite
│
├── test/                                  # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml                           # Dependencies
├── android/                               # Android config
├── ios/                                   # iOS config
├── web/                                   # Web config
└── README.md


5.2 KEY DEPENDENCIES (pubspec.yaml)
--------------------------------------------------------------------------------

name: edtech_scanner
description: Science Equipment Scanner with AI
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & API
  dio: ^5.4.0
  http: ^1.1.2
  
  # Local Storage
  sqflite: ^2.3.0
  path: ^1.8.3
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Authentication
  google_sign_in: ^6.2.1
  firebase_auth: ^4.16.0
  firebase_core: ^2.24.2
  
  # Camera & Images
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  image: ^4.1.3
  
  # UI & Design
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  lottie: ^3.0.0
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.3.3
  share_plus: ^7.2.2
  url_launcher: ^6.2.4
  connectivity_plus: ^5.0.2
  permission_handler: ^11.2.0
  
  # Optional: Offline ML
  tflite_flutter: ^0.10.4
  
  # Development
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.8

================================================================================
SECTION 6: DATABASE SCHEMAS & SQL SCRIPTS
================================================================================

6.1 POSTGRESQL DATABASE SCHEMA
--------------------------------------------------------------------------------

-- Database: edtech_scanner
-- Version: 1.0.0
-- PostgreSQL: 14+

-- Extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE users 
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE TABLE equipment 
CREATE UNIQUE INDEX idx_equipment_class_name ON equipment(class_name);
CREATE INDEX idx_equipment_category ON equipment(category);
CREATE INDEX idx_equipment_tags ON equipment USING GIN(tags);
CREATE TABLE ai_models
CREATE UNIQUE INDEX idx_ai_models_name ON ai_models(model_name);
CREATE INDEX idx_ai_models_type_active ON ai_models(model_type, is_active);
CREATE TABLE scan_metadata
CREATE INDEX idx_scan_metadata_user_id ON scan_metadata(user_id);
CREATE INDEX idx_scan_metadata_equipment_id ON scan_metadata(equipment_id);
CREATE INDEX idx_scan_metadata_scanned_at ON scan_metadata(scanned_at DESC);
CREATE TABLE api_keys 
CREATE UNIQUE INDEX idx_api_keys_service ON api_keys(service_name);

6.2 SQLITE LOCAL DATABASE SCHEMA (FLUTTER APP)
--------------------------------------------------------------------------------

-- Database: app_database.db
-- Version: 1

CREATE TABLE local_scans 
CREATE INDEX idx_local_scans_user_id ON local_scans(user_id);
CREATE INDEX idx_local_scans_timestamp ON local_scans(timestamp DESC);
CREATE INDEX idx_local_scans_equipment_id ON local_scans(equipment_id);
CREATE INDEX idx_local_scans_synced ON local_scans(synced_to_backend);
================================================================================
END OF SPECIFICATION DRIVE DOCUMENT
================================================================================

This specification drive provides a complete blueprint for developing the
EdTech Science Equipment Scanner application with:
- Custom TFLite model integration
- Flutter cross-platform frontend
- FastAPI Python backend
- PostgreSQL database
- Complete authentication system
- Full API documentation
- Implementation examples

For questions or clarifications, contact the development team lead.

Document Version: 1.0.0
Last Updated: November 30, 2025</parameter>
<parameter name="old_str">BACKEND LOGIC:
1. Validate JWT token
2. Extract user_id from token
3. INSERT INTO scan_metadata (scan_id, user_id, equipment_id, 
   confidence_score, scanned_at, device_info, synced_at)
4. Return success response

NOTE: Image files are NOT uploaded, only metadata</parameter>
</invoke>