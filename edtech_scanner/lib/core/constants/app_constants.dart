class AppConstants {
  static const String appName = 'EdTech Scanner';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String isGuestKey = 'is_guest';
  
  // Database
  static const String databaseName = 'app_database.db';
  static const int databaseVersion = 1;
  
  // Equipment Categories
  static const List<String> equipmentCategories = [
    'Microscopy',
    'Glassware',
    'Heating',
    'Measurement',
    'Safety',
    'Other',
  ];
  
  // Supported Languages
  static const String langEnglish = 'en';
  static const String langKhmer = 'km';
  
  // Scan Settings
  static const double minConfidenceThreshold = 0.5;
  static const int maxHistoryItems = 100;
}
