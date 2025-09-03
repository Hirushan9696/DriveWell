// lib/pages/mechanics_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/mechanic.dart'; // We will create this model
import 'package:intl/intl.dart'; // For date formatting if needed

class MechanicsPage extends StatefulWidget {
  final int userId;

  const MechanicsPage({super.key, required this.userId});

  @override
  State<MechanicsPage> createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  late Future<List<Mechanic>> _mechanicsFuture;

  @override
  void initState() {
    super.initState();
    _loadMechanics();
  }

  void _loadMechanics() {
    setState(() {
      _mechanicsFuture = DatabaseHelper.instance.getMechanicsForUser(widget.userId);
    });
  }

  Future<void> _addMechanic() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMechanicSheet(userId: widget.userId),
    );
    if (result == true) {
      _loadMechanics(); // Refresh list if a new record was added
    }
  }

  Future<void> _deleteMechanic(int mechanicId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
          content: const Text(
            'Are you sure you want to delete this mechanic record?',
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
        await DatabaseHelper.instance.deleteMechanic(mechanicId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mechanic deleted successfully!', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );
          _loadMechanics();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting mechanic: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error deleting mechanic: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Mechanics',
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
          FutureBuilder<List<Mechanic>>(
            future: _mechanicsFuture,
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
                        Icon(Icons.build, size: 80, color: Colors.black38), // Darker icon color
                        const SizedBox(height: 20),
                        const Text(
                          'No mechanics added yet!',
                          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap the "+" button to add your first mechanic.',
                          style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _addMechanic,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add New Mechanic',
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
                      final mechanic = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 8,
                        color: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      mechanic.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                        onPressed: () => _deleteMechanic(mechanic.id!),
                                        tooltip: 'Delete Mechanic',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (mechanic.phoneNumber != null && mechanic.phoneNumber!.isNotEmpty)
                                Text('Phone: ${mechanic.phoneNumber}', style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter')),
                              if (mechanic.address != null && mechanic.address!.isNotEmpty)
                                Text('Address: ${mechanic.address}', style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter')),
                              if (mechanic.notes != null && mechanic.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('Notes: ${mechanic.notes}', style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter')),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          // Floating Action Button positioned explicitly
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 10.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _addMechanic,
              backgroundColor: const Color.fromARGB(255, 39, 211, 0),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// AddMechanicSheet (as a separate widget or internal class)
class AddMechanicSheet extends StatefulWidget {
  final int userId;

  const AddMechanicSheet({super.key, required this.userId});

  @override
  State<AddMechanicSheet> createState() => _AddMechanicSheetState();
}

class _AddMechanicSheetState extends State<AddMechanicSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMechanic() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final Mechanic newMechanic = Mechanic(
          userId: widget.userId,
          name: _nameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

        final int result = await DatabaseHelper.instance.insertMechanic(newMechanic);

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mechanic added successfully!', style: TextStyle(fontFamily: 'Inter'))),
            );
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to add mechanic.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
        print('Error saving mechanic: $e');
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
                  'Add New Mechanic',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Darker text color
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Mechanic/Shop Name',
                    prefixIcon: const Icon(Icons.person, color: Colors.black), // Darker icon
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text color
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mechanic/shop name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: const Icon(Icons.phone, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text color
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text color
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g., Specializes in European cars, good for oil changes',
                    prefixIcon: const Icon(Icons.notes, color: Colors.black), // Darker icon color
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Dark text color
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
                        onPressed: _saveMechanic,
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
                              'Add Mechanic',
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
