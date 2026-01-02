// ==============================================================================
// FILE: lib/data/repositories/exercise_repository.dart
// UPDATED to use SQLite Database
// ==============================================================================
import '../models/exercise.dart';
import '../models/user.dart';
import '../datasources/database_helper.dart';
import '../../core/constants/enums.dart';

class ExerciseRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      final exercises = await _db.getAllExercises();
      print('📋 Total exercises in database: ${exercises.length}');
      return exercises;
    } catch (e) {
      print('❌ Error getting exercises: $e');
      return [];
    }
  }

  /// Get exercises filtered for user (matches plan and categories)
  Future<List<Exercise>> getExercisesForUser(User user) async {
    try {
      final filtered = await _db.getExercisesForUser(user);
      print('📋 Found ${filtered.length} exercises for user ${user.name}');
      return filtered;
    } catch (e) {
      print('❌ Error getting exercises for user: $e');
      return [];
    }
  }

  /// Get exercises by section type (warmup, main, cooldown)
  Future<List<Exercise>> getExercisesBySection(
      User user,
      SectionType section,
      ) async {
    try {
      final userExercises = await getExercisesForUser(user);
      final filtered = userExercises
          .where((e) => e.sectionType == section)
          .toList();
      print('📋 Found ${filtered.length} ${section.name} exercises');
      return filtered;
    } catch (e) {
      print('❌ Error getting exercises by section: $e');
      return [];
    }
  }

  /// Get exercises by body target
  Future<List<Exercise>> getExercisesByBodyTarget(
      User user,
      BodyTarget target,
      ) async {
    try {
      final userExercises = await getExercisesForUser(user);
      final filtered = userExercises
          .where((e) => e.bodyTarget == target)
          .toList();
      print('📋 Found ${filtered.length} ${target.name} exercises');
      return filtered;
    } catch (e) {
      print('❌ Error getting exercises by body target: $e');
      return [];
    }
  }

  /// Get exercises by plan type
  Future<List<Exercise>> getExercisesByPlan(Plan plan) async {
    try {
      final exercises = await _db.getExercisesByPlan(plan);
      print('📋 Found ${exercises.length} ${plan.name} exercises');
      return exercises;
    } catch (e) {
      print('❌ Error getting exercises by plan: $e');
      return [];
    }
  }

  /// Get a structured workout for user (warmup + main + cooldown)
  Future<WorkoutPlan> getWorkoutPlanForUser(User user) async {
    try {
      final warmup = await getExercisesBySection(user, SectionType.warmUp);
      final main = await getExercisesBySection(user, SectionType.mainWorkout);
      final cooldown = await getExercisesBySection(user, SectionType.coolDown);

      return WorkoutPlan(
        warmupExercises: warmup,
        mainExercises: main,
        cooldownExercises: cooldown,
        userLevel: user.selectedLevel,
      );
    } catch (e) {
      print('❌ Error creating workout plan: $e');
      return WorkoutPlan(
        warmupExercises: [],
        mainExercises: [],
        cooldownExercises: [],
        userLevel: user.selectedLevel,
      );
    }
  }
}

/// Represents a complete workout plan with sections
class WorkoutPlan {
  final List<Exercise> warmupExercises;
  final List<Exercise> mainExercises;
  final List<Exercise> cooldownExercises;
  final Level userLevel;

  WorkoutPlan({
    required this.warmupExercises,
    required this.mainExercises,
    required this.cooldownExercises,
    required this.userLevel,
  });

  /// Get total number of exercises
  int get totalExercises =>
      warmupExercises.length + mainExercises.length + cooldownExercises.length;

  /// Get estimated total duration in minutes
  int get estimatedDurationMinutes {
    int totalSeconds = 0;

    for (final exercise in [...warmupExercises, ...mainExercises, ...cooldownExercises]) {
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

  /// Check if plan is empty
  bool get isEmpty => totalExercises == 0;
}