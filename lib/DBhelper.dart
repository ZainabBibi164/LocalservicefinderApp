import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_service_finder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT,
            username TEXT,
            userType TEXT,
            phone TEXT,
            address TEXT,
            image TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE providers (
            id TEXT PRIMARY KEY,
            username TEXT,
            serviceType TEXT,
            image TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            providerId TEXT,
            FOREIGN KEY (providerId) REFERENCES providers(id)
          )
        ''');

        // Seed some provider data for testing
        await db.insert('providers', {
          'id': 'provider1',
          'username': 'John Doe',
          'serviceType': 'Electrician',
          'image': 'https://example.com/john.jpg',
        });
        await db.insert('providers', {
          'id': 'provider2',
          'username': 'Jane Smith',
          'serviceType': 'Plumber',
          'image': 'https://example.com/jane.jpg',
        });
      },
    );
  }

  Future<bool> isLoggedIn() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1);
    return users.isNotEmpty;
  }

  Future<String?> getUserType() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1);
    if (users.isEmpty) return null;
    return users.first['userType'] as String?;
  }

  Future<void> saveUser(String id, String email, String username, String userType, {String? phone, String? address, String? image}) async {
    final db = await instance.database;
    await db.insert(
      'users',
      {
        'id': id,
        'email': email,
        'username': username,
        'userType': userType,
        'phone': phone,
        'address': address,
        'image': image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearUser() async {
    final db = await instance.database;
    await db.delete('users');
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> users = await db.query('users', limit: 1);
    if (users.isEmpty) return null;
    return users.first;
  }

  Future<Map<String, dynamic>?> getProvider(String providerId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> providers = await db.query(
      'providers',
      where: 'id = ?',
      whereArgs: [providerId],
    );
    if (providers.isEmpty) return null;
    return providers.first;
  }

  Future<bool> isFavorite(String providerId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> favorites = await db.query(
      'favorites',
      where: 'providerId = ?',
      whereArgs: [providerId],
    );
    return favorites.isNotEmpty;
  }

  Future<void> addFavorite(String providerId) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      {'providerId': providerId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.query('favorites');
  }

  Future<void> deleteFavorite(int id) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    return []; // No bookings functionality for now
  }
}