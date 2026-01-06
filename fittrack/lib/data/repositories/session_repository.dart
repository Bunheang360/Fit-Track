import 'package:sqflite/sqflite.dart';
import '../models/exercise_session.dart';
import '../datasources/database_helper.dart';

class SessionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  Future<void> saveSession(ExerciseSession session) async {
    final db = await _db;
    await db.insert(
      'exercise_sessions',
      _dbHelper.sessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseSession>> getSessionsForUser(String userId) async {
    try {
      final db = await _db;
      final maps = await db.query(
        'exercise_sessions',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return maps.map((m) => _dbHelper.sessionFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ExerciseSession>> getSessionsInRange(
    String userId, {
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _db;
      final end = endDate ?? DateTime.now();
      final maps = await db.query(
        'exercise_sessions',
        where: 'userId = ? AND date >= ? AND date <= ?',
        whereArgs: [userId, startDate.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return maps.map((m) => _dbHelper.sessionFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ExerciseSession>> getTodaySessions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSessionsInRange(userId, startDate: startOfDay, endDate: endOfDay);
  }
}
