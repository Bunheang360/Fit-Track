// ==============================================================================
// FILE: lib/data/repositories/session_repository.dart
// UPDATED to use SQLite Database
// ==============================================================================
import '../models/exercise_session.dart';
import '../datasources/database_helper.dart';

class SessionRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Save a session
  Future<void> saveSession(ExerciseSession session) async {
    try {
      print('💾 Saving exercise session for user: ${session.userId}');
      await _db.insertSession(session);
      print('✅ Session saved successfully');
    } catch (e) {
      print('❌ Error saving session: $e');
      rethrow;
    }
  }

  /// Get all sessions for a user
  Future<List<ExerciseSession>> getSessionsForUser(String userId) async {
    try {
      final sessions = await _db.getSessionsForUser(userId);
      print('📊 Found ${sessions.length} sessions for user: $userId');
      return sessions;
    } catch (e) {
      print('❌ Error getting sessions: $e');
      return [];
    }
  }

  /// Get sessions for user in date range
  Future<List<ExerciseSession>> getSessionsInRange(
      String userId, {
        required DateTime startDate,
        DateTime? endDate,
      }) async {
    try {
      final end = endDate ?? DateTime.now();
      final sessions = await _db.getSessionsInRange(userId, startDate, end);
      print('📊 Found ${sessions.length} sessions in date range');
      return sessions;
    } catch (e) {
      print('❌ Error getting sessions in range: $e');
      return [];
    }
  }

  /// Get sessions for a specific exercise
  Future<List<ExerciseSession>> getSessionsForExercise(
      String userId,
      String exerciseId,
      ) async {
    try {
      final allSessions = await getSessionsForUser(userId);
      return allSessions.where((s) => s.exerciseId == exerciseId).toList();
    } catch (e) {
      print('❌ Error getting exercise sessions: $e');
      return [];
    }
  }

  /// Delete a specific session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _db.deleteSession(sessionId);
      print('✅ Session deleted: $sessionId');
    } catch (e) {
      print('❌ Error deleting session: $e');
      rethrow;
    }
  }

  /// Clear all sessions for a user
  Future<void> clearUserSessions(String userId) async {
    try {
      await _db.deleteUserSessions(userId);
      print('✅ Cleared sessions for user: $userId');
    } catch (e) {
      print('❌ Error clearing user sessions: $e');
      rethrow;
    }
  }

  /// Check if user has any sessions
  Future<bool> hasSessions(String userId) async {
    final sessions = await getSessionsForUser(userId);
    return sessions.isNotEmpty;
  }

  /// Get total sessions count for a user
  Future<int> getSessionsCount(String userId) async {
    final sessions = await getSessionsForUser(userId);
    return sessions.length;
  }

  /// Get sessions from today
  Future<List<ExerciseSession>> getTodaySessions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSessionsInRange(userId, startDate: startOfDay, endDate: endOfDay);
  }

  /// Get sessions from this week
  Future<List<ExerciseSession>> getWeekSessions(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getSessionsInRange(userId, startDate: startDate);
  }
}