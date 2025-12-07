import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // In a real app, send googleAuth.idToken to backend
      // For demo, create user from Google data
      final user = UserModel(
        userId: googleUser.id,
        email: googleUser.email,
        fullName: googleUser.displayName,
        profilePicture: googleUser.photoUrl,
        authMethod: 'google',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userIdKey, user.userId);
      await prefs.setString('auth_method', 'google');

      return user;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    // Mock OTP sending - in real app, call backend API
    await Future.delayed(const Duration(seconds: 1));
    print('OTP sent to $phoneNumber');
    // In real implementation, call backend: POST /api/auth/send-otp
  }

  Future<UserModel?> verifyOtp(String phoneNumber, String otp) async {
    // Mock OTP verification - in real app, call backend API
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo, accept any 6-digit OTP
    if (otp.length == 6) {
      final user = UserModel(
        userId: 'phone_${phoneNumber.hashCode}',
        phoneNumber: phoneNumber,
        authMethod: 'phone',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userIdKey, user.userId);
      await prefs.setString('auth_method', 'phone');

      return user;
    }
    
    return null;
  }

  Future<void> saveGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isGuestKey, true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.isGuestKey);
    await prefs.remove('auth_method');
    
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors if not signed in with Google
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    final isGuest = prefs.getBool(AppConstants.isGuestKey) ?? false;
    
    if (userId != null) {
      return UserModel(
        userId: userId,
        authMethod: prefs.getString('auth_method') ?? (isGuest ? 'guest' : 'unknown'),
        createdAt: DateTime.now(),
      );
    }
    
    return null;
  }
}
