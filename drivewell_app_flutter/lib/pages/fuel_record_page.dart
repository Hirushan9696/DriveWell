// lib/pages/fuel_record_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/fuel_record.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart'; // Import Vehicle model to update mileage
import 'package:intl/intl.dart'; // For date formatting

class FuelRecordPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const FuelRecordPage({super.key, required this.vehicleId, required this.vehicleName});

  @override
  State<FuelRecordPage> createState() => _FuelRecordPageState();
}

class _FuelRecordPageState extends State<FuelRecordPage> {
  late Future<List<FuelRecord>> _fuelRecordsFuture;

  @override
  void initState() {
    super.initState();
    _loadFuelRecords();
  }

  void _loadFuelRecords() {
    setState(() {
      _fuelRecordsFuture = DatabaseHelper.instance.getFuelRecordsForVehicle(widget.vehicleId);
    });
  }

  Future<void> _addFuelRecord() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height if needed
      backgroundColor: Colors.transparent, // Make bottom sheet transparent
      builder: (context) => AddFuelRecordSheet(vehicleId: widget.vehicleId),
    );
    if (result == true) {
      _loadFuelRecords(); // Refresh list if a new record was added
    }
  }

  Future<void> _deleteFuelRecord(int recordId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800, // Dark background for dialog
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
          content: const Text(
            'Are you sure you want to delete this fuel record? This action cannot be undone.',
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
        await DatabaseHelper.instance.deleteFuelRecord(recordId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel record deleted successfully!', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );
          _loadFuelRecords(); // Reload the list after deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting fuel record: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error deleting fuel record: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        title: Text(
          '${widget.vehicleName} Fuel Records',
          style: const TextStyle(
            color: Colors.black, // Dark text for title
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Dark icon color for contrast
      ),
      body: FutureBuilder<List<FuelRecord>>(
        future: _fuelRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0))));
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
                    Icon(Icons.local_gas_station, size: 80, color: Colors.black54), // Dark icon
                    const SizedBox(height: 20),
                    const Text(
                      'No fuel records added yet!',
                      style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the "+" button below to add your first fuel record.',
                      style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _addFuelRecord,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add First Fuel Record',
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
                                onPressed: () => _deleteFuelRecord(record.id!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Mileage: ${record.mileage.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter')),
                          Text('Fuel: ${record.fuelAmount.toStringAsFixed(2)} L (${record.fuelType})', style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Inter')),
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
        onPressed: _addFuelRecord,
        backgroundColor: const Color.fromARGB(255, 39, 211, 0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// AddFuelRecordSheet (as a separate widget or internal class)
class AddFuelRecordSheet extends StatefulWidget {
  final int vehicleId;

  const AddFuelRecordSheet({super.key, required this.vehicleId});

  @override
  State<AddFuelRecordSheet> createState() => _AddFuelRecordSheetState();
}

class _AddFuelRecordSheetState extends State<AddFuelRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _fuelAmountController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedFuelType = 'Petrol'; // Default value

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadCurrentMileage();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _mileageController.dispose();
    _fuelAmountController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentMileage() async {
    final vehicle = await DatabaseHelper.instance.getVehicleById(widget.vehicleId);
    if (vehicle != null) {
      _mileageController.text = vehicle.mileage.toStringAsFixed(1);
    }
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

  Future<void> _saveFuelRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final double newMileage = double.parse(_mileageController.text.trim());

        final Vehicle? currentVehicle = await DatabaseHelper.instance.getVehicleById(widget.vehicleId);
        if (currentVehicle != null && newMileage > currentVehicle.mileage) {
          await DatabaseHelper.instance.updateVehicle(
            currentVehicle.copyWith(mileage: newMileage),
          );
        }

        final FuelRecord newRecord = FuelRecord(
          vehicleId: widget.vehicleId,
          date: _dateController.text,
          mileage: newMileage,
          fuelAmount: double.parse(_fuelAmountController.text.trim()),
          cost: double.parse(_costController.text.trim()),
          fuelType: _selectedFuelType,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

        final int result = await DatabaseHelper.instance.insertFuelRecord(newRecord);

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fuel record added!', style: TextStyle(fontFamily: 'Inter'))),
            );
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to add fuel record.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
        print('Error saving fuel record: $e');
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
                  'Add Fuel Record',
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
                TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mileage (km)',
                    hintText: 'e.g., 55000.0',
                    prefixIcon: const Icon(Icons.speed, color: Colors.black),
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
                      return 'Please enter mileage';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _fuelAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fuel Amount (Liters)',
                    hintText: 'e.g., 30.5',
                    prefixIcon: const Icon(Icons.local_gas_station, color: Colors.black),
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
                      return 'Please enter fuel amount';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cost (Rs.)',
                    hintText: 'e.g., 5000.00',
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
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.blueGrey.shade800, // Background color of the dropdown menu
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFuelType,
                    decoration: InputDecoration(
                      labelText: 'Fuel Type',
                      prefixIcon: const Icon(Icons.opacity, color: Colors.black),
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
                    items: <String>['Petrol', 'Diesel', 'Electric', 'Hybrid']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black, fontFamily: 'Inter'), // Text color of dropdown items
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFuelType = newValue!;
                      });
                    },
                  ),
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
                        onPressed: _saveFuelRecord,
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
                              'Add Fuel Record',
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
