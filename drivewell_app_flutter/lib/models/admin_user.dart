// lib/models/admin_user.dart
class AdminUser {
  final int id;
  final String email;
  final String password;

  AdminUser({required this.id, required this.email, required this.password});

  // Convert a Map object to a User object
  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}
