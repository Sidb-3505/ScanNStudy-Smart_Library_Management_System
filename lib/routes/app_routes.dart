import 'package:flutter/material.dart';
import 'package:scan_n_study/features/auth/register_screen.dart';

import '../features/admin/admin_dashboard.dart';
import '../features/admin/live_occupancy_screen.dart';
import '../features/admin/logs_screen.dart';
import '../features/admin/qr_generator_screen.dart';
import '../features/admin/reports_screen.dart';
import '../features/admin/student_management_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/student/profile_screen.dart';
import '../features/student/scan_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/student/usage_stats_screen.dart';
import '../features/student/visit_history_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const studentHome = '/student-home';
  static const profile = '/profile';
  static const visitHistory = '/visit-history';
  static const usageStats = '/usage-stats';
  static const scan = '/scan';
  static const adminDashboard = '/admin-dashboard';
  static const studentManagement = '/student-management';
  static const liveOccupancy = '/live-occupancy';
  static const logs = '/logs';
  static const reports = '/reports';
  static const qrGenerator = '/qr-generator';
  static const register = '/register';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    studentHome: (_) => const StudentHomeScreen(),
    profile: (_) => const ProfileScreen(),
    visitHistory: (_) => const VisitHistoryScreen(),
    usageStats: (_) => const UsageStatsScreen(),
    scan: (_) => const ScanScreen(),
    adminDashboard: (_) => const AdminDashboard(),
    studentManagement: (_) => const StudentManagementScreen(),
    liveOccupancy: (_) => const LiveOccupancyScreen(),
    logs: (_) => const LogsScreen(),
    reports: (_) => const ReportsScreen(),
    qrGenerator: (_) => const QrGeneratorScreen(),
    register: (_) => const RegisterScreen(),
  };
}
