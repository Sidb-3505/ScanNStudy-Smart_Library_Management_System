import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/student_model.dart';
import '../models/visit_log_model.dart';

class DatabaseService {
  // Singleton
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  final _db = FirebaseFirestore.instance;
  final _studentsCol = 'students';
  final _logsCol = 'visitLogs';

  // ─── Local cache (keeps rest of app working synchronously) ───────────────────

  final List<Student> _students = [];
  final List<VisitLog> _visitLogs = [];

  bool _studentsLoaded = false;
  bool _logsLoaded = false;

  /// Called whenever the live Firestore listener updates the cache.
  /// VisitProvider hooks into this to call notifyListeners().
  VoidCallback? onLogsChanged;

  // ─── Init — call once at app start ───────────────────────────────────────────

  Future<void> init() async {
    await Future.wait([_loadStudents(), _loadLogs()]);
    _listenToLogs(); // real-time listener for instant dashboard updates
  }

  // ─── Firestore loaders ───────────────────────────────────────────────────────

  Future<void> _loadStudents() async {
    final snap = await _db.collection(_studentsCol).get();
    _students.clear();
    for (final doc in snap.docs) {
      _students.add(Student.fromMap(doc.data()));
    }
    _studentsLoaded = true;
  }

  Future<void> _loadLogs() async {
    final snap = await _db.collection(_logsCol).get();
    _visitLogs.clear();
    for (final doc in snap.docs) {
      _visitLogs.add(VisitLog.fromMap(doc.data()));
    }
    _logsLoaded = true;
  }

  /// Real-time listener — whenever a log is added/updated in Firestore,
  /// the local cache updates and notifies registered listeners (e.g. VisitProvider).
  void _listenToLogs() {
    _db.collection(_logsCol).snapshots().listen((snap) {
      _visitLogs.clear();
      for (final doc in snap.docs) {
        _visitLogs.add(VisitLog.fromMap(doc.data()));
      }
      onLogsChanged?.call(); // ✅ Bug 1 fix: notify VisitProvider to rebuild UI
    });
  }

  // ─── Students ────────────────────────────────────────────────────────────────

  List<Student> getAllStudents() => List.unmodifiable(_students);

  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Student? getStudentByCollegeId(String collegeId) {
    try {
      return _students.firstWhere(
            (s) => s.collegeId.toLowerCase() == collegeId.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addStudent(Student student) async {
    // Write to Firestore
    await _db.collection(_studentsCol).doc(student.id).set(student.toMap());
    // Update local cache
    _students.add(student);
  }

  Future<void> updateStudent(Student updated) async {
    await _db.collection(_studentsCol).doc(updated.id).update(updated.toMap());
    final index = _students.indexWhere((s) => s.id == updated.id);
    if (index != -1) _students[index] = updated;
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection(_studentsCol).doc(id).delete();
    _students.removeWhere((s) => s.id == id);
  }

  // ─── Visit Logs ──────────────────────────────────────────────────────────────

  List<VisitLog> getAllVisitLogs() => List.unmodifiable(_visitLogs);

  List<VisitLog> getVisitLogsForStudent(String studentId) {
    return _visitLogs.where((v) => v.studentId == studentId).toList()
      ..sort((a, b) => b.entryTime.compareTo(a.entryTime));
  }

  List<VisitLog> getActiveVisits() {
    return _visitLogs.where((v) => v.isActive).toList();
  }

  VisitLog? getActiveVisitForStudent(String studentId) {
    try {
      return _visitLogs.firstWhere(
            (v) => v.studentId == studentId && v.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  List<VisitLog> getTodayVisitLogs() {
    final today = DateTime.now();
    return _visitLogs.where((v) {
      return v.entryTime.year == today.year &&
          v.entryTime.month == today.month &&
          v.entryTime.day == today.day;
    }).toList();
  }

  Future<void> addVisitLog(VisitLog log) async {
    await _db.collection(_logsCol).doc(log.id).set(log.toMap());
    _visitLogs.add(log);
  }

  Future<void> updateVisitLog(VisitLog updated) async {
    // Only update exitTime field — don't overwrite whole document
    await _db.collection(_logsCol).doc(updated.id).update({
      'exitTime': updated.exitTime?.toIso8601String(),
    });
    final index = _visitLogs.indexWhere((v) => v.id == updated.id);
    if (index != -1) _visitLogs[index] = updated;
  }

  // ─── Analytics ───────────────────────────────────────────────────────────────

  Map<String, int> getDailyEntryCounts({int days = 7}) {
    final result = <String, int>{};
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      result[key] = _visitLogs
          .where(
            (v) =>
        v.entryTime.year == date.year &&
            v.entryTime.month == date.month &&
            v.entryTime.day == date.day,
      )
          .length;
    }
    return result;
  }
}