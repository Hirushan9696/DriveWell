// lib/pages/wheel_alignment_reminders_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/reminder.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart'; // To get vehicle mileage
import 'package:intl/intl.dart';

// Re-use WavePainter from other pages (Removed for this update)

class WheelAlignmentRemindersPage extends StatefulWidget {
  final int userId;

  const WheelAlignmentRemindersPage({super.key, required this.userId});

  @override
  State<WheelAlignmentRemindersPage> createState() => _WheelAlignmentRemindersPageState();
}

class _WheelAlignmentRemindersPageState extends State<WheelAlignmentRemindersPage> {
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      // Fetch only 'Wheel Alignment' reminders for the user
      _remindersFuture = DatabaseHelper.instance.getRemindersForUser(widget.userId)
          .then((reminders) => reminders.where((r) => r.type == 'Wheel Alignment').toList());
    });
  }

  Future<void> _addReminder() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWheelAlignmentReminderSheet(userId: widget.userId),
    );
    if (result == true) {
      _loadReminders(); // Refresh list if a new record was added
    }
  }

  Future<void> _deleteReminder(int reminderId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
          content: const Text(
            'Are you sure you want to delete this reminder?',
            style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'Inter')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await DatabaseHelper.instance.deleteReminder(reminderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder deleted successfully!', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );
          _loadReminders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting reminder: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error deleting reminder: $e');
      }
    }
  }

  Future<void> _markReminderAsComplete(Reminder reminder) async {
    setState(() {
      // Optional: Show a loading indicator if this operation is long
    });

    try {
      // Get current date for date-based reminders
      final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      double? currentMileage;

      // Get current mileage for mileage-based reminders
      if (reminder.intervalType == 'Mileage') {
        final vehicle = await DatabaseHelper.instance.getVehicleById(reminder.vehicleId);
        if (vehicle != null) {
          currentMileage = vehicle.mileage;
        } else {
          throw Exception('Vehicle not found for reminder completion.');
        }
      }

      // Calculate new nextDueDate/nextDueMileage
      String? newNextDueDate;
      double? newNextDueMileage;

      if (reminder.intervalType == 'Mileage') {
        if (currentMileage != null) {
          newNextDueMileage = currentMileage + reminder.intervalValue;
        }
      } else { // Date interval
        final lastDate = DateTime.parse(currentDate); // Use current date as last triggered
        newNextDueDate = DateFormat('yyyy-MM-dd').format(
          DateTime(lastDate.year, lastDate.month + reminder.intervalValue.toInt(), lastDate.day),
        );
      }

      // Create an updated reminder object
      final updatedReminder = reminder.copyWith(
        lastTriggeredDate: currentDate,
        lastTriggeredMileage: currentMileage,
        nextDueDate: newNextDueDate,
        nextDueMileage: newNextDueMileage,
      );

      await DatabaseHelper.instance.updateReminder(updatedReminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder marked as complete!', style: TextStyle(fontFamily: 'Inter')),
            backgroundColor: Colors.green,
          ),
        );
        _loadReminders(); // Reload the list to show updated due dates/mileages
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking reminder complete: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error marking reminder complete: $e');
    } finally {
      setState(() {
        // Optional: Hide loading indicator
      });
    }
  }

  // Helper to check if a reminder is overdue
  bool _isReminderOverdue(Reminder reminder, Vehicle? vehicle) {
    if (reminder.isActive == false) return false; // Inactive reminders are not overdue

    if (reminder.intervalType == 'Date' && reminder.nextDueDate != null) {
      final DateTime now = DateTime.now();
      final DateTime nextDue = DateTime.parse(reminder.nextDueDate!);
      // A reminder is overdue if its next due date is before today
      return nextDue.isBefore(DateTime(now.year, now.month, now.day));
    } else if (reminder.intervalType == 'Mileage' && reminder.nextDueMileage != null && vehicle != null) {
      // A reminder is overdue if current vehicle mileage is greater than or equal to next due mileage
      return vehicle.mileage >= reminder.nextDueMileage!;
    }
    return false;
  }

  // Helper to format reminder details
  Widget _buildReminderDetails(Reminder reminder) {
    String details = '';
    if (reminder.intervalType == 'Mileage') {
      details += 'Interval: ${reminder.intervalValue.toInt()} km';
      if (reminder.lastTriggeredMileage != null) {
        details += '\nLast done: ${reminder.lastTriggeredMileage!.toStringAsFixed(0)} km';
      }
      if (reminder.nextDueMileage != null) {
        details += '\nNext due: ${reminder.nextDueMileage!.toStringAsFixed(0)} km';
      }
    } else { // Date interval
      details += 'Interval: ${reminder.intervalValue.toInt()} months';
      if (reminder.lastTriggeredDate != null) {
        details += '\nLast done: ${reminder.lastTriggeredDate}';
      }
      if (reminder.nextDueDate != null) {
        details += '\nNext due: ${reminder.nextDueDate}';
      }
    }
    return Text(details, style: const TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Inter'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Wheel Alignment Reminders',
          style: TextStyle(
            color: Colors.black, // Set app bar title text color to black
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Reminder>>(
            future: _remindersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontFamily: 'Inter'),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top + 24.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 24.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tire_repair, size: 80, color: Colors.black38), // Darker icon color
                        const SizedBox(height: 20),
                        const Text(
                          'No wheel alignment reminders set yet!',
                          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap the "+" button to add your first wheel alignment reminder.',
                          style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _addReminder,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add New Reminder',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 39, 211, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final reminder = snapshot.data![index];
                      return FutureBuilder<Vehicle?>(
                        future: DatabaseHelper.instance.getVehicleById(reminder.vehicleId),
                        builder: (context, vehicleSnapshot) {
                          final bool isOverdue = _isReminderOverdue(reminder, vehicleSnapshot.data);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 8,
                            color: Colors.white.withOpacity(0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color: isOverdue ? Colors.redAccent : Colors.white10, // Red border if overdue
                                width: isOverdue ? 2.0 : 1.0, // Thicker border if overdue
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.tire_repair, color: Colors.black, size: 28), // Wheel alignment icon
                                          const SizedBox(width: 10),
                                          Text(
                                            reminder.type,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter'),
                                          ),
                                          if (isOverdue) // Add an "Overdue" text/icon
                                            const Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Icon(Icons.warning, color: Colors.redAccent, size: 20),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                                            onPressed: () => _markReminderAsComplete(reminder),
                                            tooltip: 'Mark as Complete',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                            onPressed: () => _deleteReminder(reminder.id!),
                                            tooltip: 'Delete Reminder',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (vehicleSnapshot.hasData && vehicleSnapshot.data != null)
                                    Text(
                                      'For: ${vehicleSnapshot.data!.brand} ${vehicleSnapshot.data!.model}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter'),
                                    )
                                  else if (vehicleSnapshot.connectionState == ConnectionState.waiting)
                                    const Text('Loading vehicle...', style: TextStyle(color: Colors.black54, fontFamily: 'Inter'))
                                  else
                                    const Text('Vehicle not found', style: TextStyle(color: Colors.red, fontFamily: 'Inter')),
                                  const SizedBox(height: 4),
                                  _buildReminderDetails(reminder),
                                  if (reminder.notes != null && reminder.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('Notes: ${reminder.notes}', style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter')),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: const Color.fromARGB(255, 39, 211, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// AddWheelAlignmentReminderSheet (as a separate widget or internal class)
class AddWheelAlignmentReminderSheet extends StatefulWidget {
  final int userId;

  const AddWheelAlignmentReminderSheet({super.key, required this.userId});

  @override
  State<AddWheelAlignmentReminderSheet> createState() => _AddWheelAlignmentReminderSheetState();
}

class _AddWheelAlignmentReminderSheetState extends State<AddWheelAlignmentReminderSheet> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicleId;
  String _selectedIntervalType = 'Mileage'; // Default for wheel alignment
  final TextEditingController _intervalValueController = TextEditingController();
  final TextEditingController _lastTriggeredDateController = TextEditingController();
  final TextEditingController _lastTriggeredMileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<Vehicle> _userVehicles = [];

  @override
  void initState() {
    super.initState();
    _loadUserVehicles();
    _lastTriggeredDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _intervalValueController.dispose();
    _lastTriggeredDateController.dispose();
    _lastTriggeredMileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserVehicles() async {
    final vehicles = await DatabaseHelper.instance.getVehiclesForUser(widget.userId);
    setState(() {
      _userVehicles = vehicles;
      if (_userVehicles.isNotEmpty) {
        _selectedVehicleId = _userVehicles.first.id.toString();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color.fromARGB(255, 39, 211, 0),
              onPrimary: Colors.white,
              surface: Colors.blueGrey.shade800,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.blueGrey.shade900),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _lastTriggeredDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        double? nextDueMileage;
        String? nextDueDate;

        final Vehicle? currentVehicle = await DatabaseHelper.instance.getVehicleById(int.parse(_selectedVehicleId!));

        if (_selectedIntervalType == 'Mileage') {
          final lastMileageInput = _lastTriggeredMileageController.text.trim();
          final lastMileage = lastMileageInput.isNotEmpty ? double.parse(lastMileageInput) : (currentVehicle?.mileage ?? 0.0);
          nextDueMileage = lastMileage + double.parse(_intervalValueController.text.trim());
        } else { // Date interval
          final lastDateInput = _lastTriggeredDateController.text.trim();
          final lastDate = lastDateInput.isNotEmpty ? DateTime.parse(lastDateInput) : DateTime.now();
          nextDueDate = DateFormat('yyyy-MM-dd').format(
            DateTime(lastDate.year, lastDate.month + _intervalValueController.text.toInt(), lastDate.day),
          );
        }

        final Reminder newReminder = Reminder(
          userId: widget.userId,
          vehicleId: int.parse(_selectedVehicleId!),
          type: 'Wheel Alignment', // Fixed type for this sheet
          intervalType: _selectedIntervalType,
          intervalValue: double.parse(_intervalValueController.text.trim()),
          lastTriggeredDate: _lastTriggeredDateController.text.trim().isNotEmpty ? _lastTriggeredDateController.text.trim() : null,
          lastTriggeredMileage: _lastTriggeredMileageController.text.trim().isNotEmpty ? double.parse(_lastTriggeredMileageController.text.trim()) : null,
          nextDueDate: nextDueDate,
          nextDueMileage: nextDueMileage,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          isActive: true,
        );

        final int result = await DatabaseHelper.instance.insertReminder(newReminder);

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wheel Alignment Reminder added successfully!', style: TextStyle(fontFamily: 'Inter'))),
            );
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to add wheel alignment reminder.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
        print('Error saving wheel alignment reminder: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.0,
          right: 24.0,
          top: 24.0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Add Wheel Alignment Reminder',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Darker color for text
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: 'Select Vehicle',
                    prefixIcon: const Icon(Icons.directions_car, color: Colors.black), // Dark icon
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark label color
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  dropdownColor: Colors.blueGrey.shade800,
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  items: _userVehicles.map((Vehicle vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle.id.toString(),
                      child: Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVehicleId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vehicle';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedIntervalType,
                  decoration: InputDecoration(
                    labelText: 'Interval Type',
                    prefixIcon: const Icon(Icons.timer, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  dropdownColor: Colors.blueGrey.shade800,
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  items: <String>['Mileage', 'Date']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.black, fontFamily: 'Inter')),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIntervalType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _intervalValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _selectedIntervalType == 'Mileage' ? 'Interval Value (km)' : 'Interval Value (months)',
                    hintText: _selectedIntervalType == 'Mileage' ? 'e.g., 10000' : 'e.g., 12',
                    prefixIcon: Icon(_selectedIntervalType == 'Mileage' ? Icons.speed : Icons.calendar_month, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark label text
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter interval value';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _selectedIntervalType == 'Date'
                    ? TextFormField(
                        controller: _lastTriggeredDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Last Aligned Date',
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.black), // Darker icon color
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                        ),
                        style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      )
                    : TextFormField(
                        controller: _lastTriggeredMileageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Last Aligned Mileage (km)',
                          hintText: 'e.g., 60000',
                          prefixIcon: const Icon(Icons.speed, color: Colors.black), // Darker icon color
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                        ),
                        style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last aligned mileage';
                          }
                          if (double.tryParse(value) == null || double.parse(value) < 0) {
                            return 'Enter a valid non-negative number';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any relevant notes',
                    prefixIcon: const Icon(Icons.notes, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                ),
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
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0)))
                    : ElevatedButton(
                        onPressed: _saveReminder,
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
                            child: const Text(
                              'Add Wheel Alignment Reminder',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to convert String to int safely
extension StringToIntExtension on String {
  int toInt() {
    return int.tryParse(this) ?? 0; // Default to 0 if parsing fails
  }
}
