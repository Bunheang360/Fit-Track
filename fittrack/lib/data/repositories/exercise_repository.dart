import 'package:sqflite/sqflite.dart';
import '../../core/models/exercise.dart';
import '../../core/models/user.dart';
import '../database/database_helper.dart';
import '../../core/constants/enums.dart';

class ExerciseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  /// Get all exercises from database
  Future<List<Exercise>> getAllExercises() async {
    try {
      final db = await _db;
      final maps = await db.query('exercises');
      return maps.map((m) => _dbHelper.exerciseFromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get exercises that match user's plan and categories (data filtering only)
  Future<List<Exercise>> getExercisesForUser(User user) async {
    try {
      final allExercises = await getAllExercises();
      return _filterByPlanAndCategories(allExercises, user);
    } catch (e) {
      return [];
    }
  }

  /// Filter exercises by user's plan and categories (data filtering)
  List<Exercise> _filterByPlanAndCategories(
    List<Exercise> exercises,
    User user,
  ) {
    return exercises.where((exercise) {
      // Must match user's plan
      if (exercise.plan != user.selectedPlan) return false;

      // Must have at least one matching category
      return exercise.categories.any(
        (category) => user.selectedCategories.contains(category),
      );
    }).toList();
  }

  /// Get exercises by workout section (warmup, main, cooldown)
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

  /// Get exercises filtered by body target
  Future<List<Exercise>> getExercisesByBodyTarget(
    User user,
    WorkoutType section,
    BodyTarget bodyTarget,
  ) async {
    final exercises = await getExercisesBySection(user, section);

    // Full body target includes all exercises
    if (bodyTarget == BodyTarget.fullBody) {
      return exercises;
    }

    // Filter by specific body target (also include fullBody exercises)
    return exercises.where((exercise) {
      return exercise.bodyTarget == bodyTarget ||
          exercise.bodyTarget == BodyTarget.fullBody;
    }).toList();
  }
}

/// Simple data container for exercises by section (no business logic)
class ExercisesBySection {
  final List<Exercise> warmupExercises;
  final List<Exercise> mainExercises;
  final List<Exercise> cooldownExercises;

  ExercisesBySection({
    required this.warmupExercises,
    required this.mainExercises,
    required this.cooldownExercises,
  });

  int get totalExercises =>
      warmupExercises.length + mainExercises.length + cooldownExercises.length;

  bool get isEmpty => totalExercises == 0;
}
