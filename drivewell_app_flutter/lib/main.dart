// lib/main.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/pages/login_page.dart';
import 'package:drivewell_app_flutter/pages/home_page.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/pages/admin_login_page.dart';
import 'package:drivewell_app_flutter/pages/admin_dashboard_page.dart';
import 'package:drivewell_app_flutter/pages/admin_settings_page.dart'; // Import the new settings page
import 'package:drivewell_app_flutter/pages/user_details_page.dart'; // Import the new user details page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveWell App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.blue.shade50,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/admin_login': (context) => const AdminLoginPage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
        '/admin_settings': (context) => const AdminSettingsPage(), // Add the new settings route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/user_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UserDetailsPage(user: args['user']),
          );
        }
        return null;
      },
    );
  }
}
