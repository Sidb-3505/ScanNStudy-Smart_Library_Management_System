import '../models/visit_log_model.dart';
import 'database_service.dart';
import '../core/utils/date_utils.dart';

class AnalyticsService {
  AnalyticsService._internal();
  static final AnalyticsService instance = AnalyticsService._internal();

  final _db = DatabaseService.instance;

  int getTotalVisitsForStudent(String studentId) {
    return _db.getVisitLogsForStudent(studentId).length;
  }

  Duration getTotalTimeForStudent(String studentId) {
    final logs = _db.getVisitLogsForStudent(studentId);
    Duration total = Duration.zero;
    for (final log in logs) {
      if (log.sessionDuration != null) {
        total += log.sessionDuration!;
      }
    }
    return total;
  }

  Duration getAverageSessionForStudent(String studentId) {
    final logs = _db
        .getVisitLogsForStudent(studentId)
        .where((v) => v.sessionDuration != null)
        .toList();
    if (logs.isEmpty) return Duration.zero;
    final total = logs.fold<Duration>(
      Duration.zero,
      (sum, v) => sum + v.sessionDuration!,
    );
    return Duration(microseconds: total.inMicroseconds ~/ logs.length);
  }

  int getTotalStudentsInsideNow() {
    return _db.getActiveVisits().length;
  }

  int getTotalEntriesToday() {
    return _db.getTodayVisitLogs().length;
  }

  int getTotalExitsToday() {
    return _db.getTodayVisitLogs().where((v) => !v.isActive).length;
  }

  Duration getAverageSessionToday() {
    final completedToday = _db
        .getTodayVisitLogs()
        .where((v) => v.sessionDuration != null)
        .toList();
    if (completedToday.isEmpty) return Duration.zero;
    final total = completedToday.fold<Duration>(
      Duration.zero,
      (sum, v) => sum + v.sessionDuration!,
    );
    return Duration(
        microseconds: total.inMicroseconds ~/ completedToday.length);
  }

  Map<String, int> getDailyEntryCounts({int days = 7}) {
    return _db.getDailyEntryCounts(days: days);
  }

  String formatDuration(Duration d) => AppDateUtils.formatDuration(d);
}
