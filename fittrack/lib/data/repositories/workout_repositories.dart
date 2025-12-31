import '../models/workout.dart';
import '../models/user.dart';
import '../datasources/json_file_handler.dart';
import '../../core/constants/enums.dart';

/// Repository for Workout operations
class WorkoutRepository {
  late final JsonFileHandler<Workout> _fileHandler;

  WorkoutRepository() {
    _fileHandler = JsonFileHandler<Workout>(
      fileName: 'workouts.json',
      fromJson: (json) => _workoutFromJson(json),
      toJson: (workout) => _workoutToJson(workout),
    );
  }

  /// Get all workouts
  List<Workout> getAllWorkouts() {
    return _fileHandler.readAll();
  }

  /// Get workouts filtered by user preferences
  List<Workout> getWorkoutsForUser(User user) {
    final allWorkouts = getAllWorkouts();

    return allWorkouts.where((workout) {
      // Filter by plan (home or gym)
      if (workout.plan != user.selectedPlan) {
        return false;
      }

      // Filter by categories (at least one match)
      if (!workout.matchesCategories(user.selectedCategories)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get workouts by specific category
  List<Workout> getWorkoutsByCategory(Categories category, Plan plan) {
    final allWorkouts = getAllWorkouts();
    return allWorkouts.where((workout) {
      return workout.plan == plan &&
          workout.categories.contains(category);
    }).toList();
  }

  /// Get workouts by body target
  List<Workout> getWorkoutsByBodyTarget(BodyTarget bodyTarget, Plan plan) {
    final allWorkouts = getAllWorkouts();
    return allWorkouts.where((workout) {
      return workout.plan == plan &&
          workout.bodyTarget == bodyTarget;
    }).toList();
  }

  /// Save a workout
  void saveWorkout(Workout workout) {
    try {
      final workouts = getAllWorkouts();
      // For now, just add (in a real app, you'd check for duplicates)
      workouts.add(workout);
      _fileHandler.writeAll(workouts);
      print('Workout saved: ${workout.title}');
    } catch (e) {
      print('Error saving workout: $e');
      rethrow;
    }
  }

  /// Clear all workouts
  void clearAllWorkouts() {
    _fileHandler.clear();
  }

  // Helper methods for serialization
  Workout _workoutFromJson(Map<String, dynamic> json) {
    return Workout(
      title: json['title'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List)
          .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
          .toList(),
      plan: Plan.values.firstWhere((p) => p.name == json['plan']),
      bodyTarget: BodyTarget.values.firstWhere((b) => b.name == json['bodyTarget']),
      baseSets: json['baseSets'] as int,
      baseReps: json['baseReps'] as int,
      baseDurations: json['baseDurations'] as int,
    );
  }

  Map<String, dynamic> _workoutToJson(Workout workout) {
    return {
      'title': workout.title,
      'image': workout.image,
      'description': workout.description,
      'categories': workout.categories.map((c) => c.name).toList(),
      'plan': workout.plan.name,
      'bodyTarget': workout.bodyTarget.name,
      'baseSets': workout.baseSets,
      'baseReps': workout.baseReps,
      'baseDurations': workout.baseDurations,
    };
  }
}