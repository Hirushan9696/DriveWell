// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/pages/vehicle_list_page.dart';
import 'package:drivewell_app_flutter/pages/reminders_page.dart';
import 'package:drivewell_app_flutter/pages/mechanics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? _currentUserId;
  int _selectedIndex = 0;
  late List<Widget> _pages;

  // Animation for page content transitions
  late AnimationController _pageContentAnimationController;
  late Animation<double> _pageContentFadeAnimation;

  @override
  void initState() {
    super.initState();

    _pageContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageContentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageContentAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _pageContentAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ModalRoute.of(context)?.settings.arguments as int?;
    if (userId != null && _currentUserId == null) {
      setState(() {
        _currentUserId = userId;
        _pages = [
          VehicleListPage(userId: _currentUserId!),
          RemindersPage(userId: _currentUserId!),
          MechanicsPage(userId: _currentUserId!),
        ];
      });
    }
  }

  void _onItemTapped(int index) {
    _pageContentAnimationController.reset();
    _pageContentAnimationController.forward();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageContentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 255, 0)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Full-screen white
      appBar: AppBar(
        title: const Text(
          'DriveWell',
          style: TextStyle(
            color: Color.fromARGB(255, 19, 19, 19),
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.white, // Solid white app bar
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _pageContentFadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: 'Vehicles',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm),
                label: 'Reminders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: 'Mechanics',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color.fromARGB(255, 0, 255, 0),
            unselectedItemColor: Colors.white70,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontFamily: 'Inter'),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
