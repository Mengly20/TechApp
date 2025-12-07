class ApiConstants {
  // Base URL for API
  // For development: Use localhost backend
  // For Android emulator, use: 'http://10.0.2.2:8000/api'
  // For iOS simulator, use: 'http://localhost:8000/api'
  // For web, use: 'http://localhost:8000/api'
  // For production, use: 'https://api.edtech-scanner.com/api'
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth Endpoints
  static const String googleSignIn = '/auth/google-signin';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String signOut = '/auth/signout';
  
  // Scan Endpoints
  static const String analyzeImage = '/scan/analyze';
  static const String chatWithAI = '/scan/chat';
  static const String syncScans = '/scans/sync';
  
  // Equipment Endpoints
  static const String equipmentList = '/equipment/list';
  static const String equipmentDetail = '/equipment';
  
  // User Endpoints
  static const String userProfile = '/users/profile';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // File Upload
  static const int maxImageSizeMB = 10;
}
