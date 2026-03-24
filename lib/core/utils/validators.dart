import '../constants/app_strings.dart';

class AppValidators {
  // ─── Required field check ─────────────────────────────────────────────────

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  // ─── College Email format: name.rollno@jecrcu.edu.in ─────────────────────
  // Valid:   aarav.CS2021001@jecrcu.edu.in  ✅
  // Valid:   priya.EC2022042@jecrcu.edu.in  ✅
  // Invalid: randomguy@gmail.com            ❌
  // Invalid: CS2021001                      ❌
  // Note:    ADMIN001 bypasses this check   ✅

  static String? collegeEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }

    // Admin ID bypasses email format check
    if (value.trim() == 'ADMIN001') return null;

    // Regex: anything.anything@jecrcu.edu.in
    final regex = RegExp(r'^[a-zA-Z]+\.[a-zA-Z0-9]+@jecrcu\.edu\.in$');

    if (!regex.hasMatch(value.trim())) {
      return 'Use format: name.rollno@jecrcu.edu.in';
    }

    return null;
  }

  // ─── College ID / Roll number ─────────────────────────────────────────────

  static String? collegeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 3) {
      return 'Roll number must be at least 3 characters';
    }
    return null;
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  // ─── Full name ────────────────────────────────────────────────────────────

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
