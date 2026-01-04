import 'package:sqflite/sqflite.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../datasources/database_helper.dart';
import '../../core/constants/enums.dart';

class ExerciseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  Future<List<Exercise>> getAllExercises() async {
    try {
      final db = await _db;
      final maps = await db.query('exercises');
      return maps.map((m) => _dbHelper.exerciseFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Exercise>> getExercisesForUser(User user) async {
    try {
      final all = await getAllExercises();
      final filtered = all.where((e) {
        if (e.plan != user.selectedPlan) return false;
        return e.categories.any((c) => user.selectedCategories.contains(c));
      }).toList();

      // Sort by GoalTier priority (primary first, then supportive, then recovery)
      filtered.sort((a, b) {
        final aTier = _getExercisePriority(a, user.selectedCategories);
        final bTier = _getExercisePriority(b, user.selectedCategories);
        return aTier.compareTo(bTier);
      });

      return filtered;
    } catch (e) {
      return [];
    }
  }

  /// Calculate exercise priority based on GoalTier of matching categories
  /// Lower number = higher priority (primary=0, supportive=1, recovery=2)
  int _getExercisePriority(Exercise exercise, List<Categories> userCategories) {
    int bestPriority = 3; // Default lowest priority

    for (final category in exercise.categories) {
      if (userCategories.contains(category)) {
        final tierPriority = _getTierPriority(category.tier);
        if (tierPriority < bestPriority) {
          bestPriority = tierPriority;
        }
      }
    }
    return bestPriority;
  }

  /// Convert GoalTier to numeric priority (lower = higher priority)
  int _getTierPriority(GoalTier tier) {
    switch (tier) {
      case GoalTier.primary:
        return 0;
      case GoalTier.supportive:
        return 1;
      case GoalTier.recovery:
        return 2;
    }
  }

  Future<List<Exercise>> getExercisesBySection(
    User user,
    WorkoutType section,
  ) async {
    try {
      final userExercises = await getExercisesForUser(user);
      return userExercises.where((e) => e.sectionType == section).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Exercise>> getExercisesByBodyTarget(
    User user,
    BodyTarget target,
  ) async {
    try {
      final userExercises = await getExercisesForUser(user);
      return userExercises.where((e) => e.bodyTarget == target).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Exercise>> getExercisesByPlan(Plan plan) async {
    try {
      final db = await _db;
      final maps = await db.query(
        'exercises',
        where: 'plan = ?',
        whereArgs: [plan.name],
      );
      return maps.map((m) => _dbHelper.exerciseFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get the body target focus for a specific day of week based on user's selected days
  /// Rotates through: Upper Body -> Lower Body -> Core -> Full Body
  BodyTarget getBodyTargetForDay(User user, DayOfWeek day) {
    final selectedDays = user.selectedDays;
    if (selectedDays.isEmpty) return BodyTarget.fullBody;

    final dayIndex = selectedDays.indexOf(day);
    if (dayIndex == -1) return BodyTarget.fullBody;

    // Rotate through body targets based on workout day number
    const targets = [
      BodyTarget.upperBody,
      BodyTarget.lowerBody,
      BodyTarget.core,
      BodyTarget.fullBody,
    ];
    return targets[dayIndex % targets.length];
  }

  /// Get today's body target for the user
  BodyTarget getTodaysBodyTarget(User user) {
    final today = _getCurrentDayOfWeek();
    return getBodyTargetForDay(user, today);
  }

  /// Get exercises filtered by today's body target focus
  Future<List<Exercise>> getExercisesForToday(User user) async {
    try {
      final today = _getCurrentDayOfWeek();

      // Check if today is a workout day for the user
      if (!user.selectedDays.contains(today)) {
        return []; // Rest day - no exercises
      }

      final targetBodyPart = getBodyTargetForDay(user, today);
      final userExercises = await getExercisesForUser(user);

      // For main workout: filter by body target
      // For warmup/cooldown: include fullBody exercises regardless
      return userExercises.where((e) {
        if (e.sectionType == WorkoutType.warmUp ||
            e.sectionType == WorkoutType.coolDown) {
          return true; // Include all warmup/cooldown exercises
        }
        // Main workout: match body target or fullBody exercises
        return e.bodyTarget == targetBodyPart ||
            e.bodyTarget == BodyTarget.fullBody;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get workout plan for today based on user's schedule and body target rotation
  Future<WorkoutPlan> getWorkoutPlanForToday(User user) async {
    try {
      final today = _getCurrentDayOfWeek();

      // Check if today is a workout day
      if (!user.selectedDays.contains(today)) {
        return WorkoutPlan(
          warmupExercises: [],
          mainExercises: [],
          cooldownExercises: [],
          userLevel: user.selectedLevel,
          isRestDay: true,
        );
      }

      final targetBodyPart = getBodyTargetForDay(user, today);
      final allUserExercises = await getExercisesForUser(user);

      // Get warmup exercises (all warmups)
      final warmup = allUserExercises
          .where((e) => e.sectionType == WorkoutType.warmUp)
          .toList();

      // Get main exercises filtered by today's body target
      final main = allUserExercises.where((e) {
        if (e.sectionType != WorkoutType.mainWorkout) return false;
        return e.bodyTarget == targetBodyPart ||
            e.bodyTarget == BodyTarget.fullBody;
      }).toList();

      // Get cooldown exercises (all cooldowns)
      final cooldown = allUserExercises
          .where((e) => e.sectionType == WorkoutType.coolDown)
          .toList();

      return WorkoutPlan(
        warmupExercises: warmup,
        mainExercises: main,
        cooldownExercises: cooldown,
        userLevel: user.selectedLevel,
        todaysBodyTarget: targetBodyPart,
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

  /// Get the full workout plan (all exercises, not day-filtered)
  Future<WorkoutPlan> getWorkoutPlanForUser(User user) async {
    try {
      final warmup = await getExercisesBySection(user, WorkoutType.warmUp);
      final main = await getExercisesBySection(user, WorkoutType.mainWorkout);
      final cooldown = await getExercisesBySection(user, WorkoutType.coolDown);

      return WorkoutPlan(
        warmupExercises: warmup,
        mainExercises: main,
        cooldownExercises: cooldown,
        userLevel: user.selectedLevel,
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

  DayOfWeek _getCurrentDayOfWeek() {
    final now = DateTime.now();
    return DayOfWeek.values[now.weekday - 1]; // weekday is 1-7 (Mon-Sun)
  }

  Future<void> addExercise(Exercise exercise) async {
    final db = await _db;
    await db.insert(
      'exercises',
      _dbHelper.exerciseToMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

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

  int get totalExercises =>
      warmupExercises.length + mainExercises.length + cooldownExercises.length;

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
