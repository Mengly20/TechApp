# EdTech Science Equipment Scanner

An AI-powered mobile application for identifying science laboratory equipment using image recognition and providing intelligent assistance through conversational AI.

## Features

- 🔍 **AI-Powered Scanning**: Identify science equipment using advanced AI
- 💬 **AI Chat Assistant**: Ask questions and learn about equipment
- 📊 **Scan History**: Track and manage your previous scans
- 🔐 **Multiple Auth Methods**: Google Sign-In, Phone OTP, or Guest mode
- 📱 **Cross-Platform**: Built with Flutter for iOS and Android
- 🎨 **Modern UI**: Beautiful and intuitive user interface

## Technology Stack

- **Frontend**: Flutter 3.16+
- **State Management**: Provider
- **Backend**: FastAPI (Python) - See spec for implementation
- **Database**: 
  - Local: SQLite
  - Cloud: PostgreSQL (for authenticated users)
- **AI/ML**:
  - Image Recognition: TensorFlow Lite
  - Chatbot: Google Gemini API
- **Authentication**: Google OAuth 2.0, Phone OTP

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Android device/emulator or iOS device/simulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd edtech_scanner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── core/                     # Core functionality
│   └── constants/           # App constants
├── data/                    # Data layer
│   └── models/             # Data models
├── services/               # Business logic services
├── providers/              # State management
├── screens/               # UI screens
│   ├── auth/             # Authentication screens
│   ├── home/             # Home screen
│   ├── scan/             # Scanning screens
│   ├── history/          # History screen
│   └── profile/          # Profile screen
└── widgets/              # Reusable widgets
```

## Features Overview

### Authentication
- **Guest Mode**: Quick access without sign-in (limited features)
- **Google Sign-In**: Sign in with Google account
- **Phone OTP**: Authenticate using phone number

### Scanning
1. Take a photo or select from gallery
2. AI analyzes the image
3. View equipment details, usage, and safety information
4. Chat with AI assistant for questions
5. Save to history

### History
- View all previous scans
- Search and filter scans
- Delete individual scans or clear all

### Profile
- View user information
- See scan statistics
- Access settings and preferences
- Sign out

## Mock Data

Currently, the app uses mock data for demonstration:
- Mock equipment database with 5 sample items
- Mock AI responses for chat
- Random equipment selection for scans

To connect to a real backend, update the `ApiConstants.baseUrl` in `lib/core/constants/api_constants.dart` and implement the actual API calls in the service files.

## Building for Release

### Android
```bash
flutter build apk --release
# OR for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For questions or issues, please contact the development team.

## Version

1.0.0 - Initial Release
