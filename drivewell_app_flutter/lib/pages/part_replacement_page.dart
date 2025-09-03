// lib/pages/part_replacement_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/part_replacement.dart';
import 'package:intl/intl.dart'; // For date formatting

class PartReplacementPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const PartReplacementPage({super.key, required this.vehicleId, required this.vehicleName});

  @override
  State<PartReplacementPage> createState() => _PartReplacementPageState();
}

class _PartReplacementPageState extends State<PartReplacementPage> {
  late Future<List<PartReplacement>> _partReplacementsFuture;

  // List of common parts (maximum 20 samples as requested)
  final List<String> _commonParts = [
    'Battery', 'Brake Pads (Front)', 'Brake Pads (Rear)', 'Oil Filter',
    'Air Filter', 'Cabin Filter', 'Spark Plugs', 'Tires', 'Wiper Blades',
    'Headlights', 'Tail Lights', 'Fuel Filter', 'Alternator', 'Starter Motor',
    'Water Pump', 'Timing Belt/Chain', 'Serpentine Belt', 'Radiator',
    'Shock Absorbers', 'Muffler',
  ];

  @override
  void initState() {
    super.initState();
    _loadPartReplacements();
  }

  void _loadPartReplacements() {
    setState(() {
      _partReplacementsFuture = DatabaseHelper.instance.getPartReplacementsForVehicle(widget.vehicleId);
    });
  }

  Future<void> _addPartReplacement() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make bottom sheet transparent
      builder: (context) => AddPartReplacementSheet(vehicleId: widget.vehicleId, commonParts: _commonParts),
    );
    if (result == true) {
      _loadPartReplacements(); // Refresh list if a new record was added
    }
  }

  Future<void> _deletePartReplacement(int recordId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800, // Dark background for dialog
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.black, fontFamily: 'Inter')),
          content: const Text(
            'Are you sure you want to delete this part replacement record? This action cannot be undone.',
            style: TextStyle(color: Colors.black87, fontFamily: 'Inter'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontFamily: 'Inter')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for delete action
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
        await DatabaseHelper.instance.deletePartReplacement(recordId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Part replacement record deleted successfully!', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );
          _loadPartReplacements(); // Reload the list after deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting part replacement record: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error deleting part replacement record: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${widget.vehicleName} Part Replacements',
          style: const TextStyle(
            color: Colors.black, // Dark text color for title
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<PartReplacement>>(
        future: _partReplacementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0))));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
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
                    Icon(Icons.auto_fix_high, size: 80, color: Colors.grey), // Darker icon color
                    const SizedBox(height: 20),
                    const Text(
                      'No part replacement records added yet!',
                      style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the "+" button below to add your first part replacement.',
                      style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _addPartReplacement,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add First Part Replacement',
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
                  final record = snapshot.data![index];
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
                              Text(
                                'Date: ${record.date}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                onPressed: () => _deletePartReplacement(record.id!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Part: ${record.partName}', style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter')),
                          Text('Cost: Rs. ${record.cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter')),
                          if (record.notes != null && record.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Notes: ${record.notes}', style: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addPartReplacement,
        backgroundColor: const Color.fromARGB(255, 39, 211, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// AddPartReplacementSheet (as a separate widget or internal class)
class AddPartReplacementSheet extends StatefulWidget {
  final int vehicleId;
  final List<String> commonParts;

  const AddPartReplacementSheet({super.key, required this.vehicleId, required this.commonParts});

  @override
  State<AddPartReplacementSheet> createState() => _AddPartReplacementSheetState();
}

class _AddPartReplacementSheetState extends State<AddPartReplacementSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _partNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCommonPart; // For dropdown selection
  bool _useManualPartInput = false; // To toggle between dropdown and text field

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _partNameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _savePartReplacement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        String finalPartName;
        if (_useManualPartInput) {
          finalPartName = _partNameController.text.trim();
        } else {
          finalPartName = _selectedCommonPart ?? ''; // Should not be null if validated
        }

        final PartReplacement newRecord = PartReplacement(
          vehicleId: widget.vehicleId,
          date: _dateController.text,
          partName: finalPartName,
          cost: double.parse(_costController.text.trim()),
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

        final int result = await DatabaseHelper.instance.insertPartReplacement(newRecord);

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Part replacement added!', style: TextStyle(fontFamily: 'Inter'))),
            );
            Navigator.pop(context, true); // Pop with true to indicate success
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to add part replacement record.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
        print('Error saving part replacement record: $e');
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
        color: Colors.white, // White background for the sheet
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
                  'Add Part Replacement',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _useManualPartInput
                          ? TextFormField(
                              controller: _partNameController,
                              decoration: InputDecoration(
                                labelText: 'Part Name',
                                hintText: 'e.g., Spark Plugs',
                                prefixIcon: const Icon(Icons.handyman, color: Colors.black),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter part name';
                                }
                                return null;
                              },
                            )
                          : Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.blueGrey.shade800, // Background color of the dropdown menu
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCommonPart,
                                decoration: InputDecoration(
                                  labelText: 'Select Part',
                                  prefixIcon: const Icon(Icons.category, color: Colors.black),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                                ),
                                dropdownColor: Colors.blueGrey.shade800, // Background color of the dropdown items
                                style: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Text color of selected item
                                items: widget.commonParts.map((String part) {
                                  return DropdownMenuItem<String>(
                                    value: part,
                                    child: Text(
                                      part,
                                      style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCommonPart = newValue;
                                    _partNameController.text = newValue ?? '';
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a part';
                                  }
                                  return null;
                                },
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _useManualPartInput = !_useManualPartInput;
                          _selectedCommonPart = null; // Clear dropdown selection
                          _partNameController.clear(); // Clear manual input
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 211, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      child: Text(
                        _useManualPartInput ? 'Choose from List' : 'Manual Input',
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cost (Rs.)',
                    hintText: 'e.g., 1500.00',
                    prefixIcon: const Icon(Icons.attach_money, color: Colors.black),
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontFamily: 'Inter'),
                  ),
                  style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Enter a valid cost';
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
                    prefixIcon: const Icon(Icons.notes, color: Colors.black),
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
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
                        onPressed: _savePartReplacement,
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
                              'Add Part Replacement',
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
