import '../models/exercise_session.dart';
import '../datasources/database_helper.dart';

class SessionRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> saveSession(ExerciseSession session) async {
    try {
      await _db.insertSession(session);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExerciseSession>> getSessionsForUser(String userId) async {
    try {
      return await _db.getSessionsForUser(userId);
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
      final end = endDate ?? DateTime.now();
      return await _db.getSessionsInRange(userId, startDate, end);
    } catch (e) {
      return [];
    }
  }

  Future<List<ExerciseSession>> getSessionsForExercise(
    String userId,
    String exerciseId,
  ) async {
    try {
      final allSessions = await getSessionsForUser(userId);
      return allSessions.where((s) => s.exerciseId == exerciseId).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _db.deleteSession(sessionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearUserSessions(String userId) async {
    try {
      await _db.deleteUserSessions(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasSessions(String userId) async {
    final sessions = await getSessionsForUser(userId);
    return sessions.isNotEmpty;
  }

  Future<int> getSessionsCount(String userId) async {
    final sessions = await getSessionsForUser(userId);
    return sessions.length;
  }

  Future<List<ExerciseSession>> getTodaySessions(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSessionsInRange(userId, startDate: startOfDay, endDate: endOfDay);
  }

  Future<List<ExerciseSession>> getWeekSessions(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return getSessionsInRange(userId, startDate: startDate);
  }

  Future<List<ExerciseSession>> getMonthSessions(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getSessionsInRange(userId, startDate: startOfMonth);
  }

  Future<int> getWorkoutStreak(String userId) async {
    final sessions = await getSessionsForUser(userId);
    if (sessions.isEmpty) return 0;

    // Sort by date descending
    sessions.sort((a, b) => b.date.compareTo(a.date));

    // Get unique dates
    final uniqueDates =
        sessions
            .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    int streak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if the most recent session is today or yesterday
    final daysDiff = todayDate.difference(uniqueDates.first).inDays;
    if (daysDiff > 1) return 0; // Streak is broken

    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
