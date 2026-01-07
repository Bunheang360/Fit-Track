import 'package:sqflite/sqflite.dart';
import '../../core/models/user.dart';
import '../database/database_helper.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  Future<void> saveUser(User user) async {
    final db = await _db;
    final existingUser = await getUserById(user.id);

    if (existingUser != null) {
      await db.update(
        'users',
        _dbHelper.userToMap(user),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } else {
      await db.insert(
        'users',
        _dbHelper.userToMap(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final db = await _db;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (maps.isEmpty) return null;
      return _dbHelper.userFromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      if (username.trim().isEmpty) return null;
      final db = await _db;
      final maps = await db.query(
        'users',
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [username],
      );
      if (maps.isEmpty) return null;
      return _dbHelper.userFromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  Future<bool> usernameExists(String username) async {
    if (username.trim().isEmpty) return false;
    final user = await getUserByUsername(username);
    return user != null;
  }
}
