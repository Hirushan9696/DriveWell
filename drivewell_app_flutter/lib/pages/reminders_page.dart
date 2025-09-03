// lib/pages/reminders_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/pages/maintenance_reminders_page.dart';
import 'package:drivewell_app_flutter/pages/car_wash_reminders_page.dart';
import 'package:drivewell_app_flutter/pages/wheel_alignment_reminders_page.dart';
import 'package:drivewell_app_flutter/pages/document_expiry_reminders_page.dart';

class RemindersPage extends StatefulWidget {
  final int userId;

  const RemindersPage({super.key, required this.userId});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Reminders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const Text(
              'Reminder Categories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                _buildReminderGridItem(
                  context,
                  Icons.oil_barrel,
                  'Maintenance Checks',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaintenanceRemindersPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
                _buildReminderGridItem(
                  context,
                  Icons.local_car_wash,
                  'Car Wash',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarWashRemindersPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
                _buildReminderGridItem(
                  context,
                  Icons.tire_repair,
                  'Wheel Alignment',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WheelAlignmentRemindersPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
                _buildReminderGridItem(
                  context,
                  Icons.description,
                  'Document Expiry',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentExpiryRemindersPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderGridItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 39, 211, 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}