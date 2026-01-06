import 'package:sqflite/sqflite.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../datasources/database_helper.dart';
import '../../core/constants/enums.dart';

class ExerciseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  // ==========================================
  // Get all exercises from database
  // ==========================================
  Future<List<Exercise>> getAllExercises() async {
    try {
      final db = await _db;
      final maps = await db.query('exercises');
      return maps.map((m) => _dbHelper.exerciseFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // Get exercises that match user's plan and categories
  // ==========================================
  Future<List<Exercise>> getExercisesForUser(User user) async {
    try {
      // Step 1: Get all exercises
      final allExercises = await getAllExercises();

      // Step 2: Filter by user's plan and categories
      final matchingExercises = _filterExercisesForUser(allExercises, user);

      // Step 3: Sort by priority (primary goals first)
      _sortByPriority(matchingExercises, user.selectedCategories);

      return matchingExercises;
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // Filter exercises by user's plan and categories
  // ==========================================
  List<Exercise> _filterExercisesForUser(List<Exercise> exercises, User user) {
    List<Exercise> result = [];

    for (final exercise in exercises) {
      // Must match user's plan
      if (exercise.plan != user.selectedPlan) continue;

      // Must have at least one matching category
      bool hasMatchingCategory = false;
      for (final category in exercise.categories) {
        if (user.selectedCategories.contains(category)) {
          hasMatchingCategory = true;
          break;
        }
      }

      if (hasMatchingCategory) {
        result.add(exercise);
      }
    }

    return result;
  }

  // ==========================================
  // Sort exercises by goal priority
  // Primary goals come first, then supportive, then recovery
  // ==========================================
  void _sortByPriority(
    List<Exercise> exercises,
    List<Categories> userCategories,
  ) {
    exercises.sort((a, b) {
      final priorityA = _getExercisePriority(a, userCategories);
      final priorityB = _getExercisePriority(b, userCategories);
      return priorityA.compareTo(priorityB);
    });
  }

  // ==========================================
  // Get priority number for an exercise
  // Lower number = higher priority
  // 0 = primary, 1 = supportive, 2 = recovery, 3 = no match
  // ==========================================
  int _getExercisePriority(Exercise exercise, List<Categories> userCategories) {
    int bestPriority = 3; // Default: lowest priority

    for (final category in exercise.categories) {
      if (userCategories.contains(category)) {
        int priority = _tierToPriority(category.tier);
        if (priority < bestPriority) {
          bestPriority = priority;
        }
      }
    }

    return bestPriority;
  }

  // ==========================================
  // Convert tier to priority number
  // ==========================================
  int _tierToPriority(GoalTier tier) {
    if (tier == GoalTier.primary) return 0;
    if (tier == GoalTier.supportive) return 1;
    return 2; // recovery
  }

  // ==========================================
  // Get exercises by workout section (warmup, main, cooldown)
  // ==========================================
  Future<List<Exercise>> getExercisesBySection(
    User user,
    WorkoutType section,
  ) async {
    try {
      final userExercises = await getExercisesForUser(user);

      List<Exercise> result = [];
      for (final exercise in userExercises) {
        if (exercise.sectionType == section) {
          result.add(exercise);
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // Get body target for a specific workout day
  // Rotates: Upper Body -> Lower Body -> Core -> Full Body
  // ==========================================
  BodyTarget getBodyTargetForDay(User user, DayOfWeek day) {
    final selectedDays = user.selectedDays;
    if (selectedDays.isEmpty) return BodyTarget.fullBody;

    final dayIndex = selectedDays.indexOf(day);
    if (dayIndex == -1) return BodyTarget.fullBody;

    // Rotate through body targets based on day number
    const targets = [
      BodyTarget.upperBody,
      BodyTarget.lowerBody,
      BodyTarget.core,
      BodyTarget.fullBody,
    ];
    return targets[dayIndex % targets.length];
  }

  // ==========================================
  // Get complete workout plan for user
  // ==========================================
  Future<WorkoutPlan> getWorkoutPlanForUser(User user) async {
    try {
      // Get each section separately
      final warmupExercises = await getExercisesBySection(
        user,
        WorkoutType.warmUp,
      );
      final mainExercises = await getExercisesBySection(
        user,
        WorkoutType.mainWorkout,
      );
      final cooldownExercises = await getExercisesBySection(
        user,
        WorkoutType.coolDown,
      );

      return WorkoutPlan(
        warmupExercises: warmupExercises,
        mainExercises: mainExercises,
        cooldownExercises: cooldownExercises,
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
