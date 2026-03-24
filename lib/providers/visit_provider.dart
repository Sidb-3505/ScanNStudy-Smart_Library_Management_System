import 'package:flutter/foundation.dart';

import '../models/visit_log_model.dart';
import '../services/analytics_service.dart';
import '../services/database_service.dart';
import '../services/scan_service.dart';

class VisitProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _scanService = ScanService.instance;
  final _analytics = AnalyticsService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ScanResult? _lastScanResult;
  ScanResult? get lastScanResult => _lastScanResult;

  VisitProvider() {
    // Bug 1 fix: hook into DatabaseService's live Firestore listener so the UI
    // rebuilds automatically whenever a scan is recorded (by any device).
    _db.onLogsChanged = () => notifyListeners();
  }

  // ─── Student getters ──────────────────────────────────────────────────────

  List<VisitLog> getStudentVisits(String studentId) {
    return _db.getVisitLogsForStudent(studentId);
  }

  bool isStudentInside(String studentId) {
    return _scanService.isStudentInside(studentId);
  }

  int getTotalVisits(String studentId) {
    return _analytics.getTotalVisitsForStudent(studentId);
  }

  String getTotalTimeSpent(String studentId) {
    return _analytics.formatDuration(
      _analytics.getTotalTimeForStudent(studentId),
    );
  }

  String getAvgSession(String studentId) {
    return _analytics.formatDuration(
      _analytics.getAverageSessionForStudent(studentId),
    );
  }

  // ─── Admin getters ────────────────────────────────────────────────────────

  // Fix: copy the unmodifiable list into a new mutable list before sorting
  List<VisitLog> getAllLogs() {
    final list = List<VisitLog>.from(_db.getAllVisitLogs());
    list.sort((a, b) => b.entryTime.compareTo(a.entryTime));
    return list;
  }

  List<VisitLog> getActiveVisits() => _db.getActiveVisits();

  int get studentsInsideNow => _analytics.getTotalStudentsInsideNow();
  int get totalEntriesToday => _analytics.getTotalEntriesToday();
  int get totalExitsToday => _analytics.getTotalExitsToday();

  String get avgSessionToday =>
      _analytics.formatDuration(_analytics.getAverageSessionToday());

  Map<String, int> get dailyEntryCounts => _analytics.getDailyEntryCounts();

  // ─── Scan ─────────────────────────────────────────────────────────────────

  Future<ScanResult> processScan(String qrValue, String studentId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    // Bug 2 fix: await the result directly so we return a ScanResult, not a Future<ScanResult>
    final result = await _scanService.processScan(qrValue, studentId);
    _lastScanResult = result;

    _isLoading = false;
    notifyListeners();
    return result;
  }

  void refresh() => notifyListeners();
}
