import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isGuest = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_isGuest;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signInAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = UserModel.guest();
      _isGuest = true;
      await _authService.saveGuestSession();
    } catch (e) {
      _errorMessage = 'Failed to start guest session';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _isGuest = false;
      } else {
        _errorMessage = 'Google sign-in was cancelled';
      }
    } catch (e) {
      _errorMessage = 'Failed to sign in with Google: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendOtp(phoneNumber);
    } catch (e) {
      _errorMessage = 'Failed to send OTP: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.verifyOtp(phoneNumber, otp);
      if (user != null) {
        _currentUser = user;
        _isGuest = false;
      } else {
        _errorMessage = 'Invalid OTP';
      }
    } catch (e) {
      _errorMessage = 'Failed to verify OTP: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isGuest = false;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _isGuest = user.authMethod == 'guest';
      }
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }
}
