// lib/models/vehicle.dart
class Vehicle {
  int? id; // Nullable for when the vehicle is not yet in the database
  int userId; // Foreign key to link to the user who owns this vehicle
  String brand;
  String model;
  int yom; // Year of Manufacture
  double mileage;
  String vin; // Vehicle Identification Number (should be unique)
  String? imagePath; // Path to the vehicle's image

  Vehicle({
    this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.yom,
    required this.mileage,
    required this.vin,
    this.imagePath,
  });

  // Convert a Vehicle object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'yom': yom,
      'mileage': mileage,
      'vin': vin,
      'imagePath': imagePath,
    };
  }

  // Convert a Map into a Vehicle object.
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      userId: map['userId'],
      brand: map['brand'],
      model: map['model'],
      yom: map['yom'],
      mileage: map['mileage'],
      vin: map['vin'],
      imagePath: map['imagePath'],
    );
  }

  // Helper method to create a copy with updated fields (useful for updates)
  Vehicle copyWith({
    int? id,
    int? userId,
    String? brand,
    String? model,
    int? yom,
    double? mileage,
    String? vin,
    String? imagePath,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      yom: yom ?? this.yom,
      mileage: mileage ?? this.mileage,
      vin: vin ?? this.vin,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, userId: $userId, brand: $brand, model: $model, yom: $yom, mileage: $mileage, vin: $vin, imagePath: $imagePath}';
  }
}