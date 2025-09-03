import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/models/admin_user.dart';
import 'dart:math';

// A custom painter to draw the animated wave background.
// This creates a dynamic, curved background effect for the page.
class WavePainter extends CustomPainter {
  final double wavePhase;
  final Color topColor;
  final Color bottomColor;
  final double waveHeight;
  final double waveFrequency;

  WavePainter({
    required this.wavePhase,
    required this.topColor,
    required this.bottomColor,
    this.waveHeight = 30.0,
    this.waveFrequency = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintTop = Paint()..color = topColor;
    final paintBottom = Paint()..color = bottomColor;

    final wavePath = Path();
    wavePath.moveTo(0, size.height / 2 + waveHeight * sin(wavePhase));

    // Iterate across the width to draw the sine wave.
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + waveHeight * sin((x / size.width * 2 * pi * waveFrequency) + wavePhase);
      wavePath.lineTo(x, y);
    }

    // Create and draw the top region, filling it with the top color.
    final topRegionPath = Path.from(wavePath);
    topRegionPath.lineTo(size.width, 0);
    topRegionPath.lineTo(0, 0);
    topRegionPath.close();
    canvas.drawPath(topRegionPath, paintTop);

    // Create and draw the bottom region, filling it with the bottom color.
    final bottomRegionPath = Path.from(wavePath);
    bottomRegionPath.lineTo(size.width, size.height);
    bottomRegionPath.lineTo(0, size.height);
    bottomRegionPath.close();
    canvas.drawPath(bottomRegionPath, paintBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as WavePainter).wavePhase != wavePhase ||
        (oldDelegate).topColor != topColor ||
        (oldDelegate).bottomColor != bottomColor ||
        (oldDelegate).waveHeight != waveHeight ||
        (oldDelegate).waveFrequency != waveFrequency;
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<AdminUser?>? _adminUserFuture;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  late AnimationController _pageElementsAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _adminUserFuture = _dbHelper.getAdminUser();

    _pageElementsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animations for each UI element to appear in a staggered sequence.
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _logoSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _cardSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _pageElementsAnimationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageElementsAnimationController.dispose();
    super.dispose();
  }

  // Handles the admin login or initial password setup.
  Future<void> _handleAdminLogin(bool isFirstLogin) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (isFirstLogin) {
          final newAdmin = AdminUser(id: 1, email: 'admin@drivewell.com', password: _passwordController.text);
          await _dbHelper.insertAdminUser(newAdmin);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin password set successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          }
        } else {
          final admin = await _dbHelper.getAdminUser();
          if (admin != null && admin.password == _passwordController.text) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin login successful!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            }
          } else {
            setState(() {
              _errorMessage = 'Invalid password.';
            });
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<AdminUser?>(
            future: _adminUserFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final bool isFirstLogin = snapshot.data == null;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: SlideTransition(
                      position: _logoSlideAnimation,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: Text(
                        'DriveWell',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _cardFadeAnimation,
                    child: SlideTransition(
                      position: _cardSlideAnimation,
                      child: Card(
                        elevation: 10,
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isFirstLogin ? 'Set Admin Password' : 'Admin Login',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'Inter',
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 25),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                                    fillColor: Colors.black.withOpacity(0.1),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (isFirstLogin && value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                if (isFirstLogin) ...[
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isPasswordVisible,
                                    style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      hintText: 'Confirm your password',
                                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                                      fillColor: Colors.black.withOpacity(0.1),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15.0),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Inter'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                _isLoading
                                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0))))
                                    : ElevatedButton(
                                        onPressed: () => _handleAdminLogin(isFirstLogin),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ).copyWith(
                                          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 39, 211, 0),
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            constraints: const BoxConstraints(minHeight: 50),
                                            child: Text(
                                              isFirstLogin ? 'Set Password' : 'Login',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
