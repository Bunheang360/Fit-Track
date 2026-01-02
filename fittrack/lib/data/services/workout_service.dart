import '../../../data/models/user.dart';
import '../../../data/models/workout.dart';
import '../../../data/repositories/workout_repositories.dart';
import '../../../core/constants/enums.dart';

/// Service class to handle workout-related business logic
/// Separates concerns between UI and data layers
class WorkoutService {
  final WorkoutRepository _repository;

  WorkoutService({WorkoutRepository? repository})
      : _repository = repository ?? WorkoutRepository();

  /// Get recommended workouts for a user
  List<Workout> getRecommendedWorkouts(User user) {
    try {
      return _repository.getWorkoutsForUser(user);
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  /// Filter workouts that are typically used for warm-up
  /// (exercises with flexibility or mobility focus)
  List<Workout> getWarmupWorkouts(List<Workout> workouts, {int limit = 2}) {
    return workouts
        .where((w) =>
            w.categories.contains(Categories.flexibility) ||
            w.categories.contains(Categories.mobility))
        .take(limit)
        .toList();
  }

  /// Filter workouts for main training session
  /// (excluding warm-up exercises)
  List<Workout> getMainWorkouts(List<Workout> workouts, {int limit = 4}) {
    return workouts
        .where((w) =>
            !w.categories.contains(Categories.flexibility) &&
            !w.categories.contains(Categories.mobility))
        .take(limit)
        .toList();
  }

  /// Get adjusted sets based on user's experience level
  int getAdjustedSets(Workout workout, Level userLevel) {
    return workout.getSetsForLevel(userLevel);
  }

  /// Get adjusted reps based on user's experience level
  int getAdjustedReps(Workout workout, Level userLevel) {
    return workout.getRepsForLevel(userLevel);
  }

  /// Get adjusted duration based on user's experience level
  int getAdjustedDuration(Workout workout, Level userLevel) {
    return workout.getDurationForLevel(userLevel);
  }

  /// Separate workouts into warm-up and main workout categories
  ({List<Workout> warmups, List<Workout> mains}) categorizeWorkouts(
    List<Workout> workouts,
  ) {
    return (
      warmups: getWarmupWorkouts(workouts),
      mains: getMainWorkouts(workouts),
    );
  }
}
