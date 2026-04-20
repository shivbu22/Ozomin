import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user_model.dart';

/// Firebase-backed auth provider with anonymous sign-in (OTP bypass for demo).
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  bool _isLoading = false;
  String _phoneNumber = '';
  String? _errorMessage;
  UserModel? _userProfile;

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String get phoneNumber => _phoneNumber;
  String? get errorMessage => _errorMessage;
  UserModel? get userProfile => _userProfile;
  String get uid => _auth.currentUser?.uid ?? '';

  String get userName => _userProfile?.name ?? 'Eco User';

  /// Send OTP via Firebase Phone Auth. (Mocked for testing)
  Future<bool> sendOtp(String phone) async {
    _phoneNumber = phone;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay for OTP sending
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Verify the OTP code entered by user. (Mocked for testing)
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use Anonymous Sign-In to bypass real OTP and avoid SMS quotas/crashes
      final result = await _auth.signInAnonymously();
      final user = result.user;

      if (user != null) {
        _userProfile = await _db.getUser(user.uid);

        if (_userProfile == null) {
          final displayName = _phoneNumber.isNotEmpty
              ? 'User ${_phoneNumber.substring(_phoneNumber.length > 4 ? _phoneNumber.length - 4 : 0)}'
              : 'Eco User';
          _userProfile = UserModel(
            uid: user.uid,
            name: displayName,
            phone: _phoneNumber.isNotEmpty ? '+91$_phoneNumber' : '+910000000000',
            createdAt: DateTime.now(),
          );
          await _db.setUser(_userProfile!);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sign-in failed. Please try again.';
      debugPrint('❌ Auth error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load user profile from Firestore (call on app startup/resume).
  Future<void> loadProfile() async {
    if (_auth.currentUser == null) return;
    _userProfile = await _db.getUser(_auth.currentUser!.uid);
    notifyListeners();
  }

  /// Called on app startup — if already signed in, loads the profile silently.
  Future<void> loadProfileIfLoggedIn() async {
    if (_auth.currentUser != null && _userProfile == null) {
      await loadProfile();
    }
  }

  /// Update user name.
  Future<void> updateName(String name) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(name: name);
    await _db.setUser(_userProfile!);
    notifyListeners();
  }

  /// Sign out.
  Future<void> logout() async {
    await _auth.signOut();
    _userProfile = null;
    _phoneNumber = '';
    notifyListeners();
  }
}
