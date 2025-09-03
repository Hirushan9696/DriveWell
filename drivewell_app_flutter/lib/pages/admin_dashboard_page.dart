import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/user.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<User>> _usersFuture;

  // Animation for page content transitions
  late AnimationController _pageContentAnimationController;
  late Animation<double> _pageContentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _usersFuture = _dbHelper.getAllUsers();

    // Page content transition animation
    _pageContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pageContentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageContentAnimationController,
        curve: Curves.easeIn,
      ),
    );
    _pageContentAnimationController.forward();
  }

  Future<void> _refreshUsersList() async {
    setState(() {
      _usersFuture = _dbHelper.getAllUsers();
    });
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/admin_settings');
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  void dispose() {
    _pageContentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to a clean white background
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white, // App bar background is now white
        elevation: 1, // Added a subtle shadow to the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87), // Darker icon color
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87), // Darker icon color
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _pageContentFadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshUsersList,
          child: FutureBuilder<List<User>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 60, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        'No users found.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }

              final users = snapshot.data!;
              
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Ensures RefreshIndicator works
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card for Total Users
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: Colors.white, // Changed card color to white
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Icon(Icons.people_outline, size: 30, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Users',
                                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    users.length.toString(),
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Existing User List Container
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: Colors.white, // Changed card color to white
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    user.email!.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  user.email!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  'User ID: ${user.id}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/user_details',
                                    arguments: {'user': user},
                                  );
                                  if (result == true) {
                                    _refreshUsersList();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
