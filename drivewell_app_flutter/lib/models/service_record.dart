// lib/models/service_record.dart
class ServiceRecord {
  int? id;
  int vehicleId; // Foreign key to link to the vehicle
  String date; // Stored as YYYY-MM-DD string
  String serviceType;
  String? notes;
  double cost;

  ServiceRecord({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.serviceType,
    this.notes,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'serviceType': serviceType,
      'notes': notes,
      'cost': cost,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: map['date'],
      serviceType: map['serviceType'],
      notes: map['notes'],
      cost: map['cost'],
    );
  }

  ServiceRecord copyWith({
    int? id,
    int? vehicleId,
    String? date,
    String? serviceType,
    String? notes,
    double? cost,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      serviceType: serviceType ?? this.serviceType,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
    );
  }

  @override
  String toString() {
    return 'ServiceRecord{id: $id, vehicleId: $vehicleId, date: $date, serviceType: $serviceType, cost: $cost}';
  }
}