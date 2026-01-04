import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../datasources/database_helper.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  Future<List<User>> getAllUsers() async {
    try {
      final db = await _db;
      final maps = await db.query('users');
      return maps.map((m) => _dbHelper.userFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveUser(User user) async {
    _validateUser(user);
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

  Future<User?> getUserByEmail(String email) async {
    try {
      if (email.trim().isEmpty) return null;
      final db = await _db;
      final maps = await db.query(
        'users',
        where: 'LOWER(email) = LOWER(?)',
        whereArgs: [email],
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

  Future<bool> emailExists(String email) async {
    if (email.trim().isEmpty) return false;
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<User?> validateLogin(String username, String password) async {
    try {
      final user = await getUserByUsername(username);
      if (user == null || user.password != password) return null;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> clearAllUsers() async {
    final db = await _db;
    await db.delete('users');
  }

  void _validateUser(User user) {
    if (user.name.trim().isEmpty) {
      throw Exception('Username cannot be empty');
    }
    if (user.email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (user.selectedCategories.isEmpty) {
      throw Exception('At least one category must be selected');
    }
    if (user.selectedDays.isEmpty) {
      throw Exception('At least one workout day must be selected');
    }
  }
}
