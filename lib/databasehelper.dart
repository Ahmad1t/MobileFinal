import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'devices.db');
    print('Database path: $path'); // Log the database path
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE devices(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        status INTEGER
      )
    ''');
  }

  Future<void> insertDevice(Map<String, dynamic> device) async {
    final db = await database;
    try {
      await db.insert(
        'devices',
        device,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Device inserted: $device');
    } catch (e) {
      print('Error inserting device: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final db = await database;
    return await db.query('devices');
  }

  Future<void> updateDeviceStatus(String id, bool status) async {
    final db = await database;
    await db.update(
      'devices',
      {'status': status ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDevice(String id) async {
    final db = await database;
    await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDevices() async {
    final db = await database;
    await db.delete('devices');
  }
}
