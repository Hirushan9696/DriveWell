// lib/models/fuel_record.dart
class FuelRecord {
  int? id;
  int vehicleId; // Foreign key
  String date; // Stored as YYYY-MM-DD string
  double mileage; // Odometer reading at fill-up
  double fuelAmount; // Liters/Gallons
  double cost;
  String fuelType; // E.g., Petrol, Diesel, Electric
  String? notes;

  FuelRecord({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.mileage,
    required this.fuelAmount,
    required this.cost,
    required this.fuelType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'mileage': mileage,
      'fuelAmount': fuelAmount,
      'cost': cost,
      'fuelType': fuelType,
      'notes': notes,
    };
  }

  factory FuelRecord.fromMap(Map<String, dynamic> map) {
    return FuelRecord(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: map['date'],
      mileage: map['mileage'],
      fuelAmount: map['fuelAmount'],
      cost: map['cost'],
      fuelType: map['fuelType'],
      notes: map['notes'],
    );
  }

  FuelRecord copyWith({
    int? id,
    int? vehicleId,
    String? date,
    double? mileage,
    double? fuelAmount,
    double? cost,
    String? fuelType,
    String? notes,
  }) {
    return FuelRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      cost: cost ?? this.cost,
      fuelType: fuelType ?? this.fuelType,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'FuelRecord{id: $id, vehicleId: $vehicleId, date: $date, mileage: $mileage, fuelAmount: $fuelAmount, cost: $cost, fuelType: $fuelType}';
  }
}