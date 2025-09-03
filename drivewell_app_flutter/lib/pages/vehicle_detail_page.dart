// lib/pages/vehicle_detail_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart';
import 'package:drivewell_app_flutter/pages/fuel_record_page.dart';
import 'package:drivewell_app_flutter/pages/service_record_page.dart';
import 'package:drivewell_app_flutter/pages/part_replacement_page.dart';
import 'package:drivewell_app_flutter/pages/maintenance_expense_page.dart';
import 'dart:io'; // For File operations

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to extend behind transparent AppBar
      backgroundColor: Colors.white, // Set the background to solid white
      appBar: AppBar(
        title: Text(
          '${widget.vehicle.brand} ${widget.vehicle.model}',
          style: const TextStyle(
            color: Colors.black, // Dark title text for contrast
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // No shadow
        iconTheme: const IconThemeData(color: Colors.black), // Dark icon color for contrast
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: kToolbarHeight + MediaQuery.of(context).padding.top + 16.0, // Push content down below AppBar
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            if (widget.vehicle.imagePath != null && File(widget.vehicle.imagePath!).existsSync())
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.file(
                    File(widget.vehicle.imagePath!),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade800.withOpacity(0.5),
                      child: const Icon(Icons.broken_image, size: 80, color: Colors.white54),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15), // Transparent fill
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 80, color: Colors.white54),
                      const SizedBox(height: 10),
                      const Text(
                        'No Image Available',
                        style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Vehicle Basic Details
            Card(
              elevation: 10,
              color: Colors.white.withOpacity(0.15), // Transparent white card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: Colors.white10), // Subtle border
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Dark text for title
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Divider(color: Colors.white30),
                    _buildDetailRow(context, 'Brand:', widget.vehicle.brand),
                    _buildDetailRow(context, 'Model:', widget.vehicle.model),
                    _buildDetailRow(context, 'YOM:', widget.vehicle.yom.toString()),
                    _buildDetailRow(context, 'Mileage:', '${widget.vehicle.mileage.toStringAsFixed(1)} km'),
                    _buildDetailRow(context, 'VIN:', widget.vehicle.vin),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Reduced space between details and grid
            Text(
              'Records & Maintenance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Dark text
                fontFamily: 'Inter',
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0, // Ensures square aspect ratio for items
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.local_gas_station,
                  title: 'Fuel Records',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FuelRecordPage(
                          vehicleId: widget.vehicle.id!,
                          vehicleName: '${widget.vehicle.brand} ${widget.vehicle.model}',
                        ),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.build,
                  title: 'Service Records',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceRecordPage(
                          vehicleId: widget.vehicle.id!,
                          vehicleName: '${widget.vehicle.brand} ${widget.vehicle.model}',
                        ),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.settings,
                  title: 'Parts Replacement',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartReplacementPage(
                          vehicleId: widget.vehicle.id!,
                          vehicleName: '${widget.vehicle.brand} ${widget.vehicle.model}',
                        ),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.money,
                  title: 'Maintenance Expenses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaintenanceExpensePage(
                          vehicleId: widget.vehicle.id!,
                          vehicleName: '${widget.vehicle.brand} ${widget.vehicle.model}',
                        ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Slightly wider label column
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Dark label text for contrast
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black, // Dark value text for readability
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8,
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        splashColor: const Color.fromARGB(255, 39, 211, 0).withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: const Color.fromARGB(255, 39, 211, 0)), // Larger icon for modern look
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black, // Dark text for better readability
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
