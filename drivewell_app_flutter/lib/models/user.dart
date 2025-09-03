// lib/models/user.dart
class User {
  int? id; // Nullable for when the user is not yet in the database
  String email;
  String password; // In a real app, store hashed passwords, not plain text!

  User({this.id, required this.email, required this.password});

  // Convert a User object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  // Convert a Map into a User object.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
    );
  }

  // Helper method to create a copy with updated fields (useful for updates)
  User copyWith({
    int? id,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password}';
  }
}