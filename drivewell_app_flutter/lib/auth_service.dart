// lib/auth_service.dart
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/user.dart';

// This service handles user authentication logic using SQLite.
class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Sign in a user. Returns the User object if successful, null otherwise.
  Future<User?> signIn(String email, String password) async {
    try {
      final User? user = await _dbHelper.getUserByEmail(email);
      if (user != null && user.password == password) {
        // In a real app, you'd compare hashed passwords
        return user;
      }
      return null; // Invalid credentials
    } catch (e) {
      print('Error during sign-in: $e');
      return null;
    }
  }

  // Register a new user. Returns the User object if successful, null otherwise.
  Future<User?> register(String email, String password) async {
    try {
      // Check if user already exists
      final User? existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return null; // User with this email already exists
      }

      // Create a new user object (password should be hashed in a real app)
      final User newUser = User(email: email, password: password);
      final int id = await _dbHelper.insertUser(newUser);
      if (id > 0) {
        return newUser.copyWith(id: id); // Return user with assigned ID
      }
      return null;
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }
}