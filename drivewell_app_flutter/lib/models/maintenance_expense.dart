// lib/models/maintenance_expense.dart
class MaintenanceExpense {
  int? id;
  int vehicleId; // Foreign key
  String date; // Stored as YYYY-MM-DD string
  String category;
  double amount;
  String? notes;

  MaintenanceExpense({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.category,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date,
      'category': category,
      'amount': amount,
      'notes': notes,
    };
  }

  factory MaintenanceExpense.fromMap(Map<String, dynamic> map) {
    return MaintenanceExpense(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: map['date'],
      category: map['category'],
      amount: map['amount'],
      notes: map['notes'],
    );
  }

  MaintenanceExpense copyWith({
    int? id,
    int? vehicleId,
    String? date,
    String? category,
    double? amount,
    String? notes,
  }) {
    return MaintenanceExpense(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MaintenanceExpense{id: $id, vehicleId: $vehicleId, date: $date, category: $category, amount: $amount}';
  }
}