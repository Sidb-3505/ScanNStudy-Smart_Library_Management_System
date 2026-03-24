import 'package:flutter/foundation.dart';

import '../models/student_model.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;

  List<Student> get allStudents => _db.getAllStudents();

  List<Student> searchStudents(String query) {
    if (query.trim().isEmpty) return allStudents;
    final q = query.toLowerCase();
    return allStudents.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.collegeId.toLowerCase().contains(q) ||
          s.department.toLowerCase().contains(q);
    }).toList();
  }

  Student? getStudentById(String id) => _db.getStudentById(id);

  Future<void> addStudent(Student student) async {
    await _db.addStudent(student);
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    await _db.updateStudent(student);
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    await _db.deleteStudent(id);
    notifyListeners();
  }

  Student? getStudentByCollegeId(String collegeId) {
    return _db.getStudentByCollegeId(collegeId);
  }

  void toggleBlock(String id) async {
    final student = _db.getStudentById(id);
    if (student != null) {
      await _db.updateStudent(student.copyWith(isBlocked: !student.isBlocked));
      notifyListeners();
    }
  }

  String generateStudentId() {
    return 'S${DateTime.now().millisecondsSinceEpoch}';
  }
}
