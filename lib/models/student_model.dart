class Student {
  final String id;
  final String name;
  final String collegeId;
  final String password;
  final String department;
  final String year;
  final bool isBlocked;

  const Student({
    required this.id,
    required this.name,
    required this.collegeId,
    required this.password,
    required this.department,
    required this.year,
    this.isBlocked = false,
  });

  Student copyWith({
    String? id,
    String? name,
    String? collegeId,
    String? password,
    String? department,
    String? year,
    bool? isBlocked,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      collegeId: collegeId ?? this.collegeId,
      password: password ?? this.password,
      department: department ?? this.department,
      year: year ?? this.year,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'collegeId': collegeId,
      'password': password,
      'department': department,
      'year': year,
      'isBlocked': isBlocked,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      name: map['name'] as String,
      collegeId: map['collegeId'] as String,
      password: map['password'] as String,
      department: map['department'] as String,
      year: map['year'] as String,
      isBlocked: map['isBlocked'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'Student(id: $id, name: $name, collegeId: $collegeId, department: $department, year: $year, isBlocked: $isBlocked)';
}
