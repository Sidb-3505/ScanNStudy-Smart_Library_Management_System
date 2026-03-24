class VisitLog {
  final String id;
  final String studentId;
  final String studentName;
  final String studentCollegeId;
  final DateTime entryTime;
  final DateTime? exitTime;

  const VisitLog({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentCollegeId,
    required this.entryTime,
    this.exitTime,
  });

  bool get isActive => exitTime == null;

  Duration? get sessionDuration {
    if (exitTime == null) return null;
    return exitTime!.difference(entryTime);
  }

  Duration get currentDuration {
    final end = exitTime ?? DateTime.now();
    return end.difference(entryTime);
  }

  VisitLog copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentCollegeId,
    DateTime? entryTime,
    DateTime? exitTime,
  }) {
    return VisitLog(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentCollegeId: studentCollegeId ?? this.studentCollegeId,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentCollegeId': studentCollegeId,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
    };
  }

  factory VisitLog.fromMap(Map<String, dynamic> map) {
    return VisitLog(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      studentName: map['studentName'] as String,
      studentCollegeId: map['studentCollegeId'] as String,
      entryTime: DateTime.parse(map['entryTime'] as String),
      exitTime: map['exitTime'] != null
          ? DateTime.parse(map['exitTime'] as String)
          : null,
    );
  }
}
