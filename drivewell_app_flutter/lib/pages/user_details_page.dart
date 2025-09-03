import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/user.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

// Re-use WavePainter for a consistent app design
class WavePainter extends CustomPainter {
  final double wavePhase;
  final Color topColor;
  final Color bottomColor;
  final double waveHeight;
  final double waveFrequency;

  WavePainter({
    required this.wavePhase,
    required this.topColor,
    required this.bottomColor,
    this.waveHeight = 30.0,
    this.waveFrequency = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintTop = Paint()..color = topColor;
    final paintBottom = Paint()..color = bottomColor;

    final wavePath = Path();
    wavePath.moveTo(0, size.height / 2 + waveHeight * sin(wavePhase));

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + waveHeight * sin((x / size.width * 2 * pi * waveFrequency) + wavePhase);
      wavePath.lineTo(x, y);
    }

    final topRegionPath = Path.from(wavePath);
    topRegionPath.lineTo(size.width, 0);
    topRegionPath.lineTo(0, 0);
    topRegionPath.close();
    canvas.drawPath(topRegionPath, paintTop);

    final bottomRegionPath = Path.from(wavePath);
    bottomRegionPath.lineTo(size.width, size.height);
    bottomRegionPath.lineTo(0, size.height);
    bottomRegionPath.close();
    canvas.drawPath(bottomRegionPath, paintBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as WavePainter).wavePhase != wavePhase ||
           (oldDelegate).topColor != topColor ||
           (oldDelegate).bottomColor != bottomColor ||
           (oldDelegate).waveHeight != waveHeight ||
           (oldDelegate).waveFrequency != waveFrequency;
  }
}

class UserDetailsPage extends StatefulWidget {
  final User user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Vehicle>> _vehiclesFuture;

  // Animation controllers for the background wave and page content
  // Made nullable to prevent LateInitializationError during hot reload.
  AnimationController? _waveAnimationController;
  Animation<double>? _wavePhaseAnimation;
  AnimationController? _pageContentAnimationController;
  Animation<double>? _pageContentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _dbHelper.getVehiclesForUser(widget.user.id!);

    // Background wave animation
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _wavePhaseAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _waveAnimationController!,
        curve: Curves.linear,
      ),
    );

    // Page content transition animation
    _pageContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pageContentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageContentAnimationController!,
        curve: Curves.easeIn,
      ),
    );
    _pageContentAnimationController!.forward();
  }

  Future<void> _deleteUser(BuildContext context) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the user "${widget.user.email}" and all their vehicles and data? This action cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm) {
      await _dbHelper.deleteUser(widget.user.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "${widget.user.email}" deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  // New function to generate and save the PDF report
  Future<void> _generateAndSavePdf(BuildContext context, List<Vehicle> vehicles) async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF report...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final pw.Document pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('User Report: ${widget.user.email}',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('User ID: ${widget.user.id}'),
                pw.Text('Email: ${widget.user.email}'),
                pw.Divider(height: 24, thickness: 1),
                if (vehicles.isEmpty)
                  pw.Center(child: pw.Text('This user has no vehicles added.'))
                else ...[
                  pw.Text('Vehicles:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  ...vehicles.map((vehicle) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 16.0),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (vehicle.imagePath != null && File(vehicle.imagePath!).existsSync())
                            pw.Center(
                              child: pw.Image(
                                pw.MemoryImage(File(vehicle.imagePath!).readAsBytesSync()),
                                height: 180,
                              ),
                            ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('VIN: ${vehicle.vin}'),
                          pw.Text('Year: ${vehicle.yom}'),
                          pw.Text('Mileage: ${vehicle.mileage} km'),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            );
          },
        ),
      );

      // This is the line that caused the error you saw.
      // The PlatformException indicates that the path_provider plugin
      // is not properly initialized or linked to the native platform code.
      //
      // To fix this, please ensure the `path_provider` plugin is correctly
      // added to your `pubspec.yaml` file and that you have run `flutter pub get`
      // in your terminal.
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${widget.user.id}_report.pdf');
      await file.writeAsBytes(await pdf.save());

      // Use the printing package to share or save the PDF
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: '${widget.user.id}_report.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated and saved.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _waveAnimationController?.dispose();
    _pageContentAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if animation controllers are initialized to prevent LateInitializationError
    if (_waveAnimationController == null || _pageContentAnimationController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: Text(
          widget.user.email!,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FutureBuilder<List<Vehicle>>(
            future: _vehiclesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                  tooltip: 'Generate PDF Report',
                  onPressed: () => _generateAndSavePdf(context, snapshot.data!),
                );
              }
              return const SizedBox.shrink(); // Hide the button while loading
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Delete User',
            onPressed: () => _deleteUser(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Content with Fade Animation
          FadeTransition(
            opacity: _pageContentFadeAnimation!,
            child: FutureBuilder<List<Vehicle>>(
              future: _vehiclesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final vehicles = snapshot.data ?? [];
                
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User Info Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.black,
                                      child: Text(
                                        widget.user.email!.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'User ID',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          widget.user.id!.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  widget.user.email!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.car_rental, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${vehicles.length} Vehicle${vehicles.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Vehicle List Section
                        if (vehicles.isEmpty)
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Colors.white.withOpacity(0.85),
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.directions_car_outlined, size: 60, color: Colors.black26),
                                    SizedBox(height: 16),
                                    Text(
                                      'This user has no vehicles added yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = vehicles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  color: Colors.white.withOpacity(0.9),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Vehicle Image or Placeholder
                                        Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: vehicle.imagePath != null
                                                ? Image.file(
                                                    File(vehicle.imagePath!),
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        height: 180,
                                                        color: Colors.grey[200],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.image_not_supported_outlined,
                                                            size: 80,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    height: 180,
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.directions_car,
                                                        size: 80,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '${vehicle.brand} ${vehicle.model}',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(height: 24, thickness: 1),
                                        _buildDetailRow(context, 'VIN:', vehicle.vin),
                                        _buildDetailRow(context, 'Year:', vehicle.yom.toString()),
                                        _buildDetailRow(context, 'Mileage:', '${vehicle.mileage} km'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build a row for vehicle details
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
