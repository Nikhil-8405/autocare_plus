import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'autocare.db');

    return await openDatabase(
      path,
      version: 1,    // Increment this when schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        brand TEXT,
        model TEXT,
        number TEXT,
        year TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER,
        service_type TEXT,
        service_date TEXT,
        cost REAL,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE mileage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER,
        date TEXT,
        kilometers REAL,
        fuel REAL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        vehicle_id INTEGER,
        title TEXT,
        reminder_date TEXT,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add upgrade logic here when changing DB schema
    if (oldVersion < newVersion) {
      // Example for future upgrade
      // await db.execute("ALTER TABLE vehicles ADD COLUMN color TEXT");
    }
  }

  // USER METHODS
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> checkLogin(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  // VEHICLE METHODS
  Future<int> insertVehicle(Map<String, dynamic> vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle);
  }

  Future<List<Map<String, dynamic>>> getVehiclesByUserId(int userId) async {
    final db = await database;
    return await db.query('vehicles', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateVehicle(int id, Map<String, dynamic> updatedVehicle) async {
    final db = await database;
    return await db.update('vehicles', updatedVehicle, where: 'id = ?', whereArgs: [id]);
  }

  // SERVICE METHODS
  Future<int> insertService(Map<String, dynamic> service) async {
    final db = await database;
    return await db.insert('services', service);
  }

  Future<List<Map<String, dynamic>>> getServicesByVehicleId(int vehicleId) async {
    final db = await database;
    return await db.query('services', where: 'vehicle_id = ?', whereArgs: [vehicleId], orderBy: 'service_date DESC');
  }

  // MILEAGE METHODS
  Future<int> insertMileage(Map<String, dynamic> mileage) async {
    final db = await database;
    return await db.insert('mileage', mileage);
  }

  Future<List<Map<String, dynamic>>> getMileageByVehicleId(int vehicleId) async {
    final db = await database;
    return await db.query('mileage', where: 'vehicle_id = ?', whereArgs: [vehicleId], orderBy: 'date DESC');
  }

  // REMINDER METHODS
  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder);
  }

  Future<List<Map<String, dynamic>>> getRemindersByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'reminders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'reminder_date ASC',
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
