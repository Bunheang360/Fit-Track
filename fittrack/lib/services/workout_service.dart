import '../../core/models/user.dart';
import '../../core/models/exercise.dart';
import '../../core/models/exercise_session.dart';
import '../data/repositories/exercise_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/user_repository.dart';
import '../core/constants/enums.dart';

class WorkoutService {
  final ExerciseRepository _exerciseRepository;
  final SessionRepository _sessionRepository;
  final SettingsRepository _settingsRepository;
  final UserRepository _userRepository;

  // Singleton pattern
  static final WorkoutService _instance = WorkoutService._internal();

  factory WorkoutService() => _instance;

  WorkoutService._internal()
    : _exerciseRepository = ExerciseRepository(),
      _sessionRepository = SessionRepository(),
      _settingsRepository = SettingsRepository(),
      _userRepository = UserRepository();

  // For testing
  WorkoutService.withRepositories(
    this._exerciseRepository,
    this._sessionRepository,
    this._settingsRepository,
    this._userRepository,
  );

  // ==================== DAILY EXERCISE GOALS ====================
  // These define the target number of exercises per section
  static const int warmupGoal = 2;
  static const int mainWorkoutGoal = 5;
  static const int cooldownGoal = 2;
  static const int totalDailyGoal = warmupGoal + mainWorkoutGoal + cooldownGoal;

  // ==================== BODY TARGET ROTATION ====================
  // Rotates through body targets: Upper Body -> Lower Body -> Core -> Full Body
  static const List<BodyTarget> _bodyTargetRotation = [
    BodyTarget.upperBody,
    BodyTarget.lowerBody,
    BodyTarget.core,
    BodyTarget.fullBody,
  ];

  /// Get body target for a specific workout day based on rotation
  BodyTarget getBodyTargetForDay(User user, DayOfWeek day) {
    final selectedDays = user.selectedDays;
    if (selectedDays.isEmpty) return BodyTarget.fullBody;

    final dayIndex = selectedDays.indexOf(day);
    if (dayIndex == -1) return BodyTarget.fullBody;

    // Rotate through body targets based on workout day number
    return _bodyTargetRotation[dayIndex % _bodyTargetRotation.length];
  }

  /// Get today's body target for user
  BodyTarget getTodaysBodyTarget(User user) {
    final today = _getTodayOfWeek();
    return getBodyTargetForDay(user, today);
  }

  // ==================== EXERCISE PRIORITY (Business Logic) ====================

  /// Sort exercises by goal priority: Primary goals first, then supportive, then recovery
  List<Exercise> sortByPriority(
    List<Exercise> exercises,
    List<Categories> userCategories,
  ) {
    final sorted = List<Exercise>.from(exercises);
    sorted.sort((a, b) {
      final priorityA = _getExercisePriority(a, userCategories);
      final priorityB = _getExercisePriority(b, userCategories);
      return priorityA.compareTo(priorityB);
    });
    return sorted;
  }

  /// Get priority number for an exercise
  /// Lower = higher priority: 0 = primary, 1 = supportive, 2 = recovery, 3 = no match
  int _getExercisePriority(Exercise exercise, List<Categories> userCategories) {
    int bestPriority = 3;
    for (final category in exercise.categories) {
      if (userCategories.contains(category)) {
        final priority = _tierToPriority(category.tier);
        if (priority < bestPriority) bestPriority = priority;
      }
    }
    return bestPriority;
  }

  int _tierToPriority(GoalTier tier) {
    switch (tier) {
      case GoalTier.primary:
        return 0;
      case GoalTier.supportive:
        return 1;
      case GoalTier.recovery:
        return 2;
    }
  }

  // ==================== WORKOUT PLAN GENERATION ====================

  /// Generate complete workout plan for user (with body target filtering and priority sorting)
  Future<WorkoutPlan> getWorkoutPlanForUser(User user) async {
    try {
      final todaysBodyTarget = getTodaysBodyTarget(user);

      // Get warmup exercises (not filtered by body target - warmups are general)
      var warmupExercises = await _exerciseRepository.getExercisesBySection(
        user,
        WorkoutType.warmUp,
      );
      warmupExercises = sortByPriority(
        warmupExercises,
        user.selectedCategories,
      );

      // Get main exercises filtered by today's body target
      var mainExercises = await _exerciseRepository.getExercisesByBodyTarget(
        user,
        WorkoutType.mainWorkout,
        todaysBodyTarget,
      );
      mainExercises = sortByPriority(mainExercises, user.selectedCategories);

      // Get cooldown exercises (not filtered by body target)
      var cooldownExercises = await _exerciseRepository.getExercisesBySection(
        user,
        WorkoutType.coolDown,
      );
      cooldownExercises = sortByPriority(
        cooldownExercises,
        user.selectedCategories,
      );

      return WorkoutPlan(
        warmupExercises: warmupExercises,
        mainExercises: mainExercises,
        cooldownExercises: cooldownExercises,
        userLevel: user.selectedLevel,
        todaysBodyTarget: todaysBodyTarget,
      );
    } catch (e) {
      return WorkoutPlan(
        warmupExercises: [],
        mainExercises: [],
        cooldownExercises: [],
        userLevel: user.selectedLevel,
      );
    }
  }

  // ==================== HOME SCREEN DATA ====================

  /// Loads all data needed for the home screen in one call.
  Future<HomeScreenData?> loadHomeScreenData() async {
    try {
      // Get current user
      final userId = await _settingsRepository.getCurrentUserId();
      if (userId == null) return null;

      final user = await _userRepository.getUserById(userId);
      if (user == null) return null;

      // Get workout plan (uses service's business logic)
      final workoutPlan = await getWorkoutPlanForUser(user);

      // Get today's completed exercises
      final todayProgress = await _loadTodaysProgress(userId, workoutPlan);

      // Check if today is a workout day
      final isWorkoutDay = _isTodayWorkoutDay(user);

      return HomeScreenData(
        user: user,
        workoutPlan: workoutPlan,
        completedWarmupIds: todayProgress.completedWarmupIds,
        completedMainWorkoutIds: todayProgress.completedMainWorkoutIds,
        isWorkoutDay: isWorkoutDay,
      );
    } catch (e) {
      return null;
    }
  }

  /// Loads exercises completed today by the user.
  Future<TodayProgress> _loadTodaysProgress(
    String userId,
    WorkoutPlan workoutPlan,
  ) async {
    final todaySessions = await _sessionRepository.getTodaySessions(userId);

    // Get warmup and main workout IDs
    final warmupIds = workoutPlan.warmupExercises.map((e) => e.id).toSet();
    final mainIds = workoutPlan.mainExercises.map((e) => e.id).toSet();

    // Check which exercises are completed
    final completedWarmupIds = <String>{};
    final completedMainWorkoutIds = <String>{};

    for (final session in todaySessions) {
      if (warmupIds.contains(session.exerciseId)) {
        completedWarmupIds.add(session.exerciseId);
      } else if (mainIds.contains(session.exerciseId)) {
        completedMainWorkoutIds.add(session.exerciseId);
      }
    }

    return TodayProgress(
      completedWarmupIds: completedWarmupIds,
      completedMainWorkoutIds: completedMainWorkoutIds,
    );
  }

  // ==================== EXERCISE COMPLETION ====================

  /// Saves an exercise session when user completes an exercise.
  Future<bool> completeExercise({
    required String userId,
    required Exercise exercise,
    required Level userLevel,
  }) async {
    try {
      final session = ExerciseSession(
        userId: userId,
        exerciseId: exercise.id,
        date: DateTime.now(),
        setsCompleted: exercise.getSetsForLevel(userLevel),
        repsCompleted: exercise.getRepsForLevel(userLevel),
        durationSeconds: exercise.getDurationForLevel(userLevel),
      );

      await _sessionRepository.saveSession(session);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== SCHEDULE LOGIC ====================

  /// Get today's day of week
  DayOfWeek _getTodayOfWeek() {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=Monday, 6=Sunday
    return DayOfWeek.values[todayIndex];
  }

  /// Checks if today is a workout day for the user.
  bool _isTodayWorkoutDay(User user) {
    final today = _getTodayOfWeek();
    return user.selectedDays.contains(today);
  }

  /// Gets the name of the next workout day.
  String getNextWorkoutDay(User user) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    for (int i = 1; i <= 7; i++) {
      final checkIndex = (todayIndex + i) % 7;
      final checkDay = DayOfWeek.values[checkIndex];
      if (user.selectedDays.contains(checkDay)) {
        return checkDay.name[0].toUpperCase() + checkDay.name.substring(1);
      }
    }
    return 'Not scheduled';
  }
}

// ==================== WORKOUT PLAN ====================
/// Contains the exercises for a user's daily workout with business logic
class WorkoutPlan {
  final List<Exercise> warmupExercises;
  final List<Exercise> mainExercises;
  final List<Exercise> cooldownExercises;
  final Level userLevel;
  final BodyTarget? todaysBodyTarget;
  final bool isRestDay;

  WorkoutPlan({
    required this.warmupExercises,
    required this.mainExercises,
    required this.cooldownExercises,
    required this.userLevel,
    this.todaysBodyTarget,
    this.isRestDay = false,
  });

  // Goals from service
  static int get warmupGoal => WorkoutService.warmupGoal;
  static int get mainWorkoutGoal => WorkoutService.mainWorkoutGoal;
  static int get cooldownGoal => WorkoutService.cooldownGoal;

  int get totalExercises =>
      warmupExercises.length + mainExercises.length + cooldownExercises.length;

  /// Check if user has enough exercises to meet goals
  bool get hasEnoughWarmup => warmupExercises.length >= warmupGoal;
  bool get hasEnoughMain => mainExercises.length >= mainWorkoutGoal;
  bool get hasEnoughCooldown => cooldownExercises.length >= cooldownGoal;

  /// Estimated duration based on user level
  int get estimatedDurationMinutes {
    int totalSeconds = 0;

    for (final exercise in [
      ...warmupExercises,
      ...mainExercises,
      ...cooldownExercises,
    ]) {
      final sets = exercise.getSetsForLevel(userLevel);
      final duration = exercise.getDurationForLevel(userLevel);
      final rest = exercise.restPeriod;

      if (duration > 0) {
        // Duration-based exercise
        totalSeconds += (duration * sets) + (rest * (sets - 1));
      } else {
        // Rep-based exercise (estimate 3 seconds per rep)
        final reps = exercise.getRepsForLevel(userLevel);
        totalSeconds += (reps * 3 * sets) + (rest * (sets - 1));
      }
    }

    return (totalSeconds / 60).ceil();
  }

  bool get isEmpty => totalExercises == 0;
}

/// HOME SCREEN DATA
// Contains all data needed for the home screen.
class HomeScreenData {
  final User user;
  final WorkoutPlan workoutPlan;
  final Set<String> completedWarmupIds;
  final Set<String> completedMainWorkoutIds;
  final bool isWorkoutDay;

  HomeScreenData({
    required this.user,
    required this.workoutPlan,
    required this.completedWarmupIds,
    required this.completedMainWorkoutIds,
    required this.isWorkoutDay,
  });

  // === GOAL-BASED PROGRESS ===

  // Warmup goal (target number of warmup exercises)
  int get warmupGoal => WorkoutPlan.warmupGoal;

  // Main workout goal (target number of main exercises)
  int get mainWorkoutGoal => WorkoutPlan.mainWorkoutGoal;

  // Number of warmup exercises completed today (capped at goal)
  int get warmupCompleted => completedWarmupIds.length.clamp(0, warmupGoal);

  // Number of main workout exercises completed today (capped at goal)
  int get mainWorkoutCompleted =>
      completedMainWorkoutIds.length.clamp(0, mainWorkoutGoal);

  // Total available warmup exercises to choose from
  int get warmupAvailable => workoutPlan.warmupExercises.length;

  // Total available main workout exercises to choose from
  int get mainWorkoutAvailable => workoutPlan.mainExercises.length;

  // Progress toward warmup goal (0.0 to 1.0)
  double get warmupProgress =>
      warmupGoal > 0 ? warmupCompleted / warmupGoal : 0.0;

  // Progress toward main workout goal (0.0 to 1.0)
  double get mainWorkoutProgress =>
      mainWorkoutGoal > 0 ? mainWorkoutCompleted / mainWorkoutGoal : 0.0;

  // Overall daily progress (0.0 to 1.0)
  double get overallProgress {
    final totalGoal = warmupGoal + mainWorkoutGoal;
    if (totalGoal == 0) return 0.0;
    return (warmupCompleted + mainWorkoutCompleted) / totalGoal;
  }

  // Warmup exercises remaining to reach goal
  int get warmupRemaining =>
      (warmupGoal - warmupCompleted).clamp(0, warmupGoal);

  // Main workout exercises remaining to reach goal
  int get mainWorkoutRemaining =>
      (mainWorkoutGoal - mainWorkoutCompleted).clamp(0, mainWorkoutGoal);

  // Check if warmup goal is completed
  bool get isWarmupGoalComplete => warmupCompleted >= warmupGoal;

  // Check if main workout goal is completed
  bool get isMainWorkoutGoalComplete => mainWorkoutCompleted >= mainWorkoutGoal;

  // Check if daily workout is fully complete
  bool get isDailyGoalComplete =>
      isWarmupGoalComplete && isMainWorkoutGoalComplete;

  // Estimated remaining minutes for warmup (based on remaining goal)
  int get warmupRemainingMinutes => warmupRemaining * 2;

  // Estimated remaining minutes for main workout (based on remaining goal)
  int get mainWorkoutRemainingMinutes => mainWorkoutRemaining * 5;

  // Today's body target (Upper Body, Lower Body, Core, or Full Body)
  String get todaysBodyTarget =>
      workoutPlan.todaysBodyTarget?.displayName ?? 'Full Body';
}

/// TODAY PROGRESS
// Tracks which exercises have been completed today.
class TodayProgress {
  final Set<String> completedWarmupIds;
  final Set<String> completedMainWorkoutIds;

  TodayProgress({
    required this.completedWarmupIds,
    required this.completedMainWorkoutIds,
  });
}
