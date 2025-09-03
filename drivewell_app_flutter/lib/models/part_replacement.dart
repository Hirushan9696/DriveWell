// lib/models/part_replacement.dart
class PartReplacement {
  int? id;
  int vehicleId; // Foreign key
  String date; // Stored as YYYY-MM-DD string
  String partName;
  double cost;
  String? notes;

  PartReplacement({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.partName,
    required this.cost,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'partName': partName,
      'cost': cost,
      'notes': notes,
    };
  }

  factory PartReplacement.fromMap(Map<String, dynamic> map) {
    return PartReplacement(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: map['date'],
      partName: map['partName'],
      cost: map['cost'],
      notes: map['notes'],
    );
  }

  PartReplacement copyWith({
    int? id,
    int? vehicleId,
    String? date,
    String? partName,
    double? cost,
    String? notes,
  }) {
    return PartReplacement(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      partName: partName ?? this.partName,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'PartReplacement{id: $id, vehicleId: $vehicleId, date: $date, partName: $partName, cost: $cost}';
  }
}