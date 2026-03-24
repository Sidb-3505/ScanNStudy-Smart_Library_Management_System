import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'database_service.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ─── SharedPreferences keys ───────────────────────────────────────────────
  static const _keyCollegeId = 'saved_college_id';
  static const _keyPassword  = 'saved_password';
  static const _keyRole      = 'saved_role';

  // ─── Try restoring session from disk ─────────────────────────────────────
  /// Called once at splash screen. Returns true if a valid saved session exists.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId   = prefs.getString(_keyCollegeId);
    final savedPass = prefs.getString(_keyPassword);

    if (savedId == null || savedPass == null) return false;

    // Re-run login logic using saved credentials
    final user = login(savedId, savedPass, persist: false);
    return user != null;
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  /// [persist] = true saves credentials to disk (normal login)
  /// [persist] = false just validates (used by autoLogin, no re-save)
  UserModel? login(String collegeId, String password, {bool persist = true}) {
    UserModel? user;

    // Admin check
    if (collegeId == AppConstants.adminId &&
        password == AppConstants.adminPassword) {
      user = const UserModel(
        id: 'ADMIN',
        collegeId: AppConstants.adminId,
        name: 'Library Admin',
        role: UserRole.admin,
      );
    } else {
      // Student check — support both raw collegeId AND email format
      String resolvedId = collegeId;
      if (collegeId.contains('@jecrcu.edu.in')) {
        final localPart = collegeId.split('@').first;
        final dotIndex  = localPart.indexOf('.');
        if (dotIndex != -1) {
          resolvedId = localPart.substring(dotIndex + 1);
        }
      }

      final student =
          DatabaseService.instance.getStudentByCollegeId(resolvedId);
      if (student != null &&
          student.password == password &&
          !student.isBlocked) {
        user = UserModel(
          id: student.id,
          collegeId: student.collegeId,
          name: student.name,
          role: UserRole.student,
        );
      }
    }

    if (user != null) {
      _currentUser = user;
      if (persist) _saveSession(collegeId, password);
    }

    return user;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCollegeId);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyRole);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────
  Future<void> _saveSession(String collegeId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCollegeId, collegeId);
    await prefs.setString(_keyPassword, password);
  }
}
