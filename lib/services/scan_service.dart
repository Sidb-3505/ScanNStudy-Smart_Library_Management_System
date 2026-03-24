import '../core/constants/app_constants.dart';
import '../models/visit_log_model.dart';
import 'database_service.dart';

enum ScanResult { entry, exit, invalid, blocked }

class ScanService {
  ScanService._internal();
  static final ScanService instance = ScanService._internal();

  final _db = DatabaseService.instance;

  /// Processes a scan.
  ///
  /// Two modes:
  ///   1. Student scans library QR → [qrValue] = LIBRARY_SMART_ENTRY_2024,
  ///      [studentId] = logged-in student's ID.
  ///   2. Admin scanner scans student's personal QR card →
  ///      [qrValue] = LIBRARY_SMART_ENTRY_2024 (admin bypass),
  ///      [studentId] = extracted from STUDENT_QR:<id>.
  Future<ScanResult> processScan(String qrValue, String studentId) async {
    if (qrValue != AppConstants.libraryQrValue) {
      return ScanResult.invalid;
    }

    final student = _db.getStudentById(studentId);
    if (student == null) return ScanResult.invalid;
    if (student.isBlocked) return ScanResult.blocked;

    final activeVisit = _db.getActiveVisitForStudent(studentId);

    if (activeVisit != null) {
      final updatedLog = activeVisit.copyWith(exitTime: DateTime.now());
      await _db.updateVisitLog(updatedLog); // ← await added
      return ScanResult.exit;
    } else {
      final newLog = VisitLog(
        id: 'V${DateTime.now().millisecondsSinceEpoch}',
        studentId: student.id,
        studentName: student.name,
        studentCollegeId: student.collegeId,
        entryTime: DateTime.now(),
      );
      await _db.addVisitLog(newLog); // ← await added
      return ScanResult.entry;
    }
  }

  bool isStudentInside(String studentId) {
    return _db.getActiveVisitForStudent(studentId) != null;
  }
}
