import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService.instance;

  UserModel? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Auto login (called from splash) ─────────────────────────────────────
  Future<bool> tryAutoLogin() async {
    return await _authService.tryAutoLogin();
  }

  // ─── Manual login ─────────────────────────────────────────────────────────
  Future<bool> login(String collegeId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final user = _authService.login(collegeId, password);
    _isLoading = false;

    if (user == null) {
      _errorMessage = 'Invalid credentials or account is blocked.';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
