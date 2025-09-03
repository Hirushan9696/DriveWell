// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:drivewell_app_flutter/models/user.dart';
import 'package:drivewell_app_flutter/models/vehicle.dart';
import 'package:drivewell_app_flutter/models/service_record.dart';
import 'package:drivewell_app_flutter/models/part_replacement.dart';
import 'package:drivewell_app_flutter/models/maintenance_expense.dart';
import 'package:drivewell_app_flutter/models/fuel_record.dart';
import 'package:drivewell_app_flutter/models/reminder.dart';
import 'package:drivewell_app_flutter/models/mechanic.dart';
import 'package:drivewell_app_flutter/models/admin_user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'drivewell_app.db');
    return await openDatabase(
      path,
      version: 4, // Increment version for new methods
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
    // Create Vehicles table (updated with imagePath)
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        brand TEXT,
        model TEXT,
        yom INTEGER,
        mileage REAL,
        vin TEXT UNIQUE,
        imagePath TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    // Create ServiceRecords table
    await db.execute('''
      CREATE TABLE service_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT,
        serviceType TEXT,
        notes TEXT,
        cost REAL,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
    // Create PartReplacements table
    await db.execute('''
      CREATE TABLE part_replacements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT,
        partName TEXT,
        cost REAL,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
    // Create MaintenanceExpenses table
    await db.execute('''
      CREATE TABLE maintenance_expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT,
        category TEXT,
        amount REAL,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
    // Create FuelRecords table
    await db.execute('''
      CREATE TABLE fuel_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT,
        mileage REAL,
        fuelAmount REAL,
        cost REAL,
        fuelType TEXT,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
    // Create Reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        vehicleId INTEGER,
        type TEXT,
        intervalType TEXT,
        intervalValue REAL,
        lastTriggeredDate TEXT,
        lastTriggeredMileage REAL,
        nextDueDate TEXT,
        nextDueMileage REAL,
        notes TEXT,
        isActive INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
    // Create Mechanics table
    await db.execute('''
      CREATE TABLE mechanics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        name TEXT,
        phoneNumber TEXT,
        address TEXT,
        notes TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    // Create AdminUser table
    await db.execute('''
      CREATE TABLE admin_users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          vehicleId INTEGER,
          type TEXT,
          intervalType TEXT,
          intervalValue REAL,
          lastTriggeredDate TEXT,
          lastTriggeredMileage REAL,
          nextDueDate TEXT,
          nextDueMileage REAL,
          notes TEXT,
          isActive INTEGER,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE mechanics(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          name TEXT,
          phoneNumber TEXT,
          address TEXT,
          notes TEXT,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE admin_users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');
    }
  }

  // --- Admin User Operations ---
  Future<int> insertAdminUser(AdminUser adminUser) async {
    Database db = await instance.database;
    return await db.insert('admin_users', adminUser.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AdminUser?> getAdminUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('admin_users');
    if (maps.isNotEmpty) {
      return AdminUser.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAdminUser(AdminUser adminUser) async {
    Database db = await instance.database;
    return await db.update(
      'admin_users',
      adminUser.toMap(),
      where: 'id = ?',
      whereArgs: [adminUser.id],
    );
  }

  // --- User Operations ---
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  // New: Get all users
  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('users', orderBy: 'email ASC');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // New: Delete a user and all related data
  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Vehicle Operations ---
  Future<int> insertVehicle(Vehicle vehicle) async {
    Database db = await instance.database;
    return await db.insert('vehicles', vehicle.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Vehicle>> getVehiclesForUser(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'brand ASC, model ASC',
    );
    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  Future<Vehicle?> getVehicleById(int vehicleId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    Database db = await instance.database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // --- Service Record Operations ---
  Future<int> insertServiceRecord(ServiceRecord record) async {
    Database db = await instance.database;
    return await db.insert('service_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ServiceRecord>> getServiceRecordsForVehicle(int vehicleId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'service_records',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => ServiceRecord.fromMap(maps[i]));
  }

  Future<int> updateServiceRecord(ServiceRecord record) async {
    Database db = await instance.database;
    return await db.update('service_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteServiceRecord(int id) async {
    Database db = await instance.database;
    return await db.delete('service_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Part Replacement Operations ---
  Future<int> insertPartReplacement(PartReplacement record) async {
    Database db = await instance.database;
    return await db.insert('part_replacements', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PartReplacement>> getPartReplacementsForVehicle(int vehicleId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'part_replacements',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => PartReplacement.fromMap(maps[i]));
  }

  Future<int> updatePartReplacement(PartReplacement record) async {
    Database db = await instance.database;
    return await db.update('part_replacements', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deletePartReplacement(int id) async {
    Database db = await instance.database;
    return await db.delete('part_replacements', where: 'id = ?', whereArgs: [id]);
  }

  // --- Maintenance Expense Operations ---
  Future<int> insertMaintenanceExpense(MaintenanceExpense record) async {
    Database db = await instance.database;
    return await db.insert('maintenance_expenses', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MaintenanceExpense>> getMaintenanceExpensesForVehicle(int vehicleId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'maintenance_expenses',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MaintenanceExpense.fromMap(maps[i]));
  }

  Future<int> updateMaintenanceExpense(MaintenanceExpense record) async {
    Database db = await instance.database;
    return await db.update('maintenance_expenses', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteMaintenanceExpense(int id) async {
    Database db = await instance.database;
    return await db.delete('maintenance_expenses', where: 'id = ?', whereArgs: [id]);
  }

  // --- Fuel Record Operations ---
  Future<int> insertFuelRecord(FuelRecord record) async {
    Database db = await instance.database;
    return await db.insert('fuel_records', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FuelRecord>> getFuelRecordsForVehicle(int vehicleId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'fuel_records',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FuelRecord.fromMap(maps[i]));
  }

  Future<int> updateFuelRecord(FuelRecord record) async {
    Database db = await instance.database;
    return await db.update('fuel_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<int> deleteFuelRecord(int id) async {
    Database db = await instance.database;
    return await db.delete('fuel_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminder Operations ---
  Future<int> insertReminder(Reminder reminder) async {
    Database db = await instance.database;
    return await db.insert('reminders', reminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reminder>> getRemindersForUser(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'nextDueDate ASC, nextDueMileage ASC',
    );
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  Future<int> updateReminder(Reminder reminder) async {
    Database db = await instance.database;
    return await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<int> deleteReminder(int id) async {
    Database db = await instance.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Mechanic Operations ---
  Future<int> insertMechanic(Mechanic mechanic) async {
    Database db = await instance.database;
    return await db.insert('mechanics', mechanic.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Mechanic>> getMechanicsForUser(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'mechanics',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Mechanic.fromMap(maps[i]));
  }

  Future<int> updateMechanic(Mechanic mechanic) async {
    Database db = await instance.database;
    return await db.update('mechanics', mechanic.toMap(), where: 'id = ?', whereArgs: [mechanic.id]);
  }

  Future<int> deleteMechanic(int id) async {
    Database db = await instance.database;
    return await db.delete('mechanics', where: 'id = ?', whereArgs: [id]);
  }
}
