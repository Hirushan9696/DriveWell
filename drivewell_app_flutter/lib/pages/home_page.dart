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

  // AI chat pop-up
  void _openAIChat() {
    showDialog(
      context: context,
      barrierDismissible: false, // force explicit close
      builder: (_) => const AIChatMockDialog(),
    );
  }

  // OPTIONAL: Page-specific FAB (replace with your real actions or return null)
  Widget? _buildPageFab() {
    final themeGreen = const Color.fromARGB(255, 0, 255, 0);

    switch (_selectedIndex) {
      case 1: // Reminders tab
        return FloatingActionButton(
          heroTag: 'page-fab-reminders',
          tooltip: 'Add Reminder',
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Reminder (stub)')),
            );
          },
          child: const Icon(Icons.add_alarm),
        );
      case 2: // Mechanics tab
        return FloatingActionButton(
          heroTag: 'page-fab-mechanics',
          tooltip: 'Find Mechanic',
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Find Mechanic (stub)')),
            );
          },
          child: const Icon(Icons.search),
        );
      default:
        return null;
    }
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

    final themeGreen = const Color.fromARGB(255, 0, 255, 0);

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

      // === Two FABs side-by-side (page FAB + AI FAB) ===
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(
        builder: (context) {
          final bottomSafe = MediaQuery.of(context).padding.bottom;
          const extraGap = 16.0; // fine-tune vertical spacing above bottom bar

          final pageFab = _buildPageFab();

          // Build horizontally aligned row of FABs
          final fabs = <Widget>[
            if (pageFab != null) pageFab,
            FloatingActionButton(
              heroTag: 'ai-fab',
              tooltip: 'Open AI Chat',
              backgroundColor: themeGreen,
              foregroundColor: Colors.black,
              onPressed: _openAIChat,
              child: const Icon(Icons.smart_toy_outlined),
            ),
          ];

          return Padding(
            padding: EdgeInsets.only(
              bottom: bottomSafe + kBottomNavigationBarHeight + extraGap,
              right: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add a little horizontal gap between the two FABs
                for (int i = 0; i < fabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  fabs[i],
                ],
              ],
            ),
          );
        },
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
            selectedItemColor: themeGreen,
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

// Simple mock AI chat dialog with close button
class AIChatMockDialog extends StatefulWidget {
  const AIChatMockDialog({super.key});

  @override
  State<AIChatMockDialog> createState() => _AIChatMockDialogState();
}

class _AIChatMockDialogState extends State<AIChatMockDialog> {
  final List<_ChatMsg> _messages = <_ChatMsg>[
    const _ChatMsg(sender: _Sender.ai, text: "Hi! I’m DriveWell AI. How can I help you today?"),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(sender: _Sender.me, text: text));
      _controller.clear();
      // Very simple mock response
      _messages.add(_ChatMsg(
        sender: _Sender.ai,
        text: "Thanks! (mock) I received: \"$text\"",
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeGreen = const Color.fromARGB(255, 0, 255, 0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 560),
        child: Column(
          children: [
            // Header with title + Close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: Colors.black),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'DriveWell AI',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m.sender == _Sender.me;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: isMe ? themeGreen.withOpacity(0.18) : Colors.grey.shade200,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isMe ? 14 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 14),
                        ),
                        border: Border.all(color: isMe ? themeGreen.withOpacity(0.6) : Colors.grey.shade300),
                      ),
                      child: Text(
                        m.text,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle: const TextStyle(fontFamily: 'Inter'),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: themeGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Sender { me, ai }

class _ChatMsg {
  final _Sender sender;
  final String text;
  const _ChatMsg({required this.sender, required this.text});
}
