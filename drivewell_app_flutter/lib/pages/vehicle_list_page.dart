// lib/pages/vehicle_list_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart';
import 'package:drivewell_app_flutter/pages/add_vehicle_page.dart';
import 'package:drivewell_app_flutter/pages/vehicle_detail_page.dart';
import 'dart:io'; // For File operations

class VehicleListPage extends StatefulWidget {
  final int userId;

  const VehicleListPage({super.key, required this.userId});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = DatabaseHelper.instance.getVehiclesForUser(widget.userId);
    });
  }

  Future<void> _deleteVehicle(int vehicleId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
          content: const Text(
            'Are you sure you want to delete this vehicle record? This action cannot be undone.',
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
        await DatabaseHelper.instance.deleteVehicle(vehicleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle deleted successfully!', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );
          _loadVehicles();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting vehicle: ${e.toString()}', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error deleting vehicle: $e');
      }
    }
  }

  void _navigateToAddVehicle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVehiclePage(userId: widget.userId)),
    );
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the full screen background to white
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0))));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading vehicles: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontFamily: 'Inter'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 24.0,
                  bottom: MediaQuery.of(context).padding.bottom + 120.0,
                  left: 24.0,
                  right: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No vehicles added yet!',
                      style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the "+" button below to add your first vehicle.',
                      style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(
                top:  MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom + 10.0,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final vehicle = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 8,
                    color: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleDetailPage(vehicle: vehicle),
                          ),
                        ).then((_) => _loadVehicles());
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      splashColor: const Color.fromARGB(255, 39, 211, 0).withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (vehicle.imagePath != null && File(vehicle.imagePath!).existsSync())
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.file(
                                  File(vehicle.imagePath!),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 180,
                                    color: Colors.grey.shade800.withOpacity(0.5),
                                    child: const Icon(Icons.broken_image, size: 60, color: Colors.white54),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${vehicle.brand} ${vehicle.model} (${vehicle.yom})',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Inter',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                  onPressed: () => _deleteVehicle(vehicle.id!),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('VIN: ${vehicle.vin}', style: const TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter')),
                            const SizedBox(height: 4),
                            Text('Mileage: ${vehicle.mileage.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Inter')),
                          ],
                        ),
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
      floatingActionButton: Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 10.0, // Adjust this value to move it higher
        right: 16.0,
        child: FloatingActionButton(
          onPressed: _navigateToAddVehicle,
          backgroundColor: const Color.fromARGB(255, 39, 211, 0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
