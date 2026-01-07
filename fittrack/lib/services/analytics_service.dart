import '../../core/models/exercise_session.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/user_repository.dart';
import '../core/constants/enums.dart';

class AnalyticsService {
  final SessionRepository _sessionRepository;
  final UserRepository _userRepository;

  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal()
    : _sessionRepository = SessionRepository(),
      _userRepository = UserRepository();

  // For testing
  AnalyticsService.withRepositories(
    this._sessionRepository,
    this._userRepository,
  );

  // LOAD ANALYTICS DATA

  /// Loads all analytics data for a user.
  Future<AnalyticsData?> loadAnalyticsData(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      final sessions = await _sessionRepository.getSessionsForUser(userId);
      final registrationDate = user?.createdAt ?? DateTime.now();

      return AnalyticsData(
        sessions: sessions,
        registrationDate: registrationDate,
      );
    } catch (e) {
      return null;
    }
  }

  // CALCULATE CHART DATA

  /// Calculates chart data based on the selected period.
  ChartData calculateChartData({
    required AnalyticsData data,
    required AnalyticsPeriod period,
  }) {
    switch (period) {
      case AnalyticsPeriod.days:
        return _calculateDailyData(data.sessions);
      case AnalyticsPeriod.weeks:
        return _calculateWeeklyData(data);
      case AnalyticsPeriod.months:
        return _calculateMonthlyData(data);
    }
  }

  // DAILY DATA (Current Week)

  ChartData _calculateDailyData(List<ExerciseSession> sessions) {
    final now = DateTime.now();

    // Find Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final labels = <String>[];
    final values = <int>[];

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final count = _countSessionsOnDate(sessions, day);
      labels.add(DayOfWeek.values[i].shortName);
      values.add(count);
    }

    return ChartData(
      labels: labels,
      values: values,
      totalExercises: values.fold(0, (sum, val) => sum + val),
    );
  }

  /// WEEKLY DATA (From Registration)

  ChartData _calculateWeeklyData(AnalyticsData data) {
    final now = DateTime.now();
    final regDate = data.registrationDate;

    // Find Monday of registration week
    final regMonday = regDate.subtract(Duration(days: regDate.weekday - 1));
    final week1Start = DateTime(regMonday.year, regMonday.month, regMonday.day);

    // Find Monday of current week
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekStart = DateTime(
      currentMonday.year,
      currentMonday.month,
      currentMonday.day,
    );

    // Calculate total weeks
    final daysDiff = currentWeekStart.difference(week1Start).inDays;
    final totalWeeks = (daysDiff / 7).floor() + 1;

    final labels = <String>[];
    final values = <int>[];

    for (int week = 0; week < totalWeeks; week++) {
      final weekStart = week1Start.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count = _countSessionsInRange(data.sessions, weekStart, weekEnd);

      labels.add('W${week + 1}');
      values.add(count);
    }

    return ChartData(
      labels: labels,
      values: values,
      totalExercises: values.fold(0, (sum, val) => sum + val),
    );
  }

  /// MONTHLY DATA (From Registration)

  ChartData _calculateMonthlyData(AnalyticsData data) {
    final now = DateTime.now();
    final regDate = data.registrationDate;
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    int startYear = regDate.year;
    int startMonth = regDate.month;
    int endYear = now.year;
    int endMonth = now.month;

    int totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

    final labels = <String>[];
    final values = <int>[];

    for (int i = 0; i < totalMonths; i++) {
      int year = startYear + ((startMonth - 1 + i) ~/ 12);
      int month = ((startMonth - 1 + i) % 12) + 1;

      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 1);
      final count = _countSessionsInRange(data.sessions, monthStart, monthEnd);

      // Show year if different from current year
      if (year != now.year) {
        labels.add("${monthNames[month - 1]}\n'${year % 100}");
      } else {
        labels.add(monthNames[month - 1]);
      }
      values.add(count);
    }

    return ChartData(
      labels: labels,
      values: values,
      totalExercises: values.fold(0, (sum, val) => sum + val),
    );
  }

  /// HELPER METHODS

  int _countSessionsOnDate(List<ExerciseSession> sessions, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _countSessionsInRange(sessions, dayStart, dayEnd);
  }

  int _countSessionsInRange(
    List<ExerciseSession> sessions,
    DateTime start,
    DateTime end,
  ) {
    int count = 0;
    for (final session in sessions) {
      if (session.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          session.date.isBefore(end)) {
        count++;
      }
    }
    return count;
  }
}

/// ANALYTICS DATA
// Raw analytics data loaded from database.
class AnalyticsData {
  final List<ExerciseSession> sessions;
  final DateTime registrationDate;

  AnalyticsData({required this.sessions, required this.registrationDate});
}

/// CHART DATA
// Processed data ready for chart display.
class ChartData {
  final List<String> labels;
  final List<int> values;
  final int totalExercises;

  ChartData({
    required this.labels,
    required this.values,
    required this.totalExercises,
  });

  int get maxValue =>
      values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
}
