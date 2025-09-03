// lib/pages/add_vehicle_page.dart
import 'package:flutter/material.dart';
import 'package:drivewell_app_flutter/database_helper.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddVehiclePage extends StatefulWidget {
  final int userId;

  const AddVehiclePage({super.key, required this.userId});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yomController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();

  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _pageElementsAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();

    _pageElementsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _cardSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageElementsAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _pageElementsAnimationController.forward();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yomController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _pageElementsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final Vehicle newVehicle = Vehicle(
          userId: widget.userId,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          yom: int.parse(_yomController.text.trim()),
          mileage: double.parse(_mileageController.text.trim()),
          vin: _vinController.text.trim(),
          imagePath: _vehicleImage?.path,
        );

        final int result = await DatabaseHelper.instance.insertVehicle(newVehicle);

        if (result > 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vehicle added successfully!', style: TextStyle(fontFamily: 'Inter')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to add vehicle. VIN might already exist.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error adding vehicle: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white, // Set background to solid white
      appBar: AppBar(
        title: const Text(
          'Add New Vehicle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Removed the wave animation
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _cardFadeAnimation,
                child: SlideTransition(
                  position: _cardSlideAnimation,
                  child: Card(
                    elevation: 10,
                    color: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Enter Vehicle Details',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: _vehicleImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: Image.file(
                                          _vehicleImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 60,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Tap to add vehicle image',
                                            style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _brandController,
                              decoration: InputDecoration(
                                labelText: 'Brand',
                                hintText: 'e.g., Toyota',
                                prefixIcon: const Icon(Icons.car_repair, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the vehicle brand';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _modelController,
                              decoration: InputDecoration(
                                labelText: 'Model',
                                hintText: 'e.g., Camry',
                                prefixIcon: const Icon(Icons.model_training, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the vehicle model';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _yomController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Year of Manufacture',
                                hintText: 'e.g., 2020',
                                prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the year of manufacture';
                                }
                                if (int.tryParse(value) == null || int.parse(value) < 1900 || int.parse(value) > DateTime.now().year + 1) {
                                  return 'Please enter a valid year';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _mileageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Current Mileage',
                                hintText: 'e.g., 50000.5',
                                prefixIcon: const Icon(Icons.speed, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the current mileage';
                                }
                                if (double.tryParse(value) == null || double.parse(value) < 0) {
                                  return 'Please enter a valid mileage';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _vinController,
                              decoration: InputDecoration(
                                labelText: 'VIN Number',
                                hintText: 'Enter Vehicle Identification Number',
                                prefixIcon: const Icon(Icons.numbers, color: Colors.white),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter'),
                              ),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the VIN number';
                                }
                                if (value.length < 17) {
                                  return 'VIN must be at least 17 characters';
                                }
                                return null;
                              },
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
                                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 39, 211, 0))))
                                : ElevatedButton(
                                    onPressed: _addVehicle,
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
                                          'Add Vehicle',
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
