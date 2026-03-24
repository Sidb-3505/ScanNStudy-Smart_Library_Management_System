enum UserRole { student, admin }

class UserModel {
  final String id;
  final String collegeId;
  final String name;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.collegeId,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;

  UserModel copyWith({
    String? id,
    String? collegeId,
    String? name,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      collegeId: collegeId ?? this.collegeId,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collegeId': collegeId,
      'name': name,
      'role': role.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      collegeId: map['collegeId'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
    );
  }
}
