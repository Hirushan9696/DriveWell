// lib/models/mechanic.dart
class Mechanic {
  int? id; // Nullable for when the mechanic is not yet in the database
  int userId; // Foreign key to link to the user who added this mechanic
  String name;
  String? phoneNumber;
  String? address;
  String? notes;

  Mechanic({
    this.id,
    required this.userId,
    required this.name,
    this.phoneNumber,
    this.address,
    this.notes,
  });

  // Convert a Mechanic object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'notes': notes,
    };
  }

  // Convert a Map into a Mechanic object.
  factory Mechanic.fromMap(Map<String, dynamic> map) {
    return Mechanic(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      notes: map['notes'],
    );
  }

  // Helper method to create a copy with updated fields (useful for updates)
  Mechanic copyWith({
    int? id,
    int? userId,
    String? name,
    String? phoneNumber,
    String? address,
    String? notes,
  }) {
    return Mechanic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Mechanic{id: $id, userId: $userId, name: $name, phoneNumber: $phoneNumber, address: $address, notes: $notes}';
  }
}
