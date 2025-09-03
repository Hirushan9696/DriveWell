// lib/models/reminder.dart
class Reminder {
  int? id;
  final int userId;
  final int vehicleId;
  final String type; // e.g., 'Oil Change', 'Tire Pressure', 'Car Wash', 'Document Expiry'
  final String intervalType; // 'Mileage' or 'Date'
  final double intervalValue; // The value for the interval (e.g., 5000 for mileage, 3 for months)
  final String? lastTriggeredDate; // Date when the reminder was last completed (yyyy-MM-dd)
  final double? lastTriggeredMileage; // Mileage when the reminder was last completed
  final String? nextDueDate; // Calculated next due date (yyyy-MM-dd)
  final double? nextDueMileage; // Calculated next due mileage
  final String? notes;
  final bool isActive; // To enable/disable the reminder

  Reminder({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.type,
    required this.intervalType,
    required this.intervalValue,
    this.lastTriggeredDate,
    this.lastTriggeredMileage,
    this.nextDueDate,
    this.nextDueMileage,
    this.notes,
    this.isActive = true,
  });

  // Convert a Reminder object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'type': type,
      'intervalType': intervalType,
      'intervalValue': intervalValue,
      'lastTriggeredDate': lastTriggeredDate,
      'lastTriggeredMileage': lastTriggeredMileage,
      'nextDueDate': nextDueDate,
      'nextDueMileage': nextDueMileage,
      'notes': notes,
      'isActive': isActive ? 1 : 0, // SQLite stores booleans as integers (0 or 1)
    };
  }

  // Extract a Reminder object from a Map object
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      userId: map['userId'],
      vehicleId: map['vehicleId'],
      type: map['type'],
      intervalType: map['intervalType'],
      intervalValue: map['intervalValue'],
      lastTriggeredDate: map['lastTriggeredDate'],
      lastTriggeredMileage: map['lastTriggeredMileage'],
      nextDueDate: map['nextDueDate'],
      nextDueMileage: map['nextDueMileage'],
      notes: map['notes'],
      isActive: map['isActive'] == 1,
    );
  }

  // Helper method to create a copy with updated values
  Reminder copyWith({
    int? id,
    int? userId,
    int? vehicleId,
    String? type,
    String? intervalType,
    double? intervalValue,
    String? lastTriggeredDate,
    double? lastTriggeredMileage,
    String? nextDueDate,
    double? nextDueMileage,
    String? notes,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      intervalType: intervalType ?? this.intervalType,
      intervalValue: intervalValue ?? this.intervalValue,
      lastTriggeredDate: lastTriggeredDate ?? this.lastTriggeredDate,
      lastTriggeredMileage: lastTriggeredMileage ?? this.lastTriggeredMileage,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueMileage: nextDueMileage ?? this.nextDueMileage,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
