import '../../core/constants/enums.dart';

class Workout {
  Workout({
    required this.title,
    required this.image,
    required this.description,
    required this.categories,
    required this.plan,
    required this.bodyTarget,
    required this.baseSets,
    required this.baseReps,
    required this.baseDurations,
  });

  final String title;
  final String image;
  final String description;
  final List<Categories> categories;
  final Plan plan;
  final BodyTarget bodyTarget;
  final int baseSets;
  final int baseReps;
  final int baseDurations;

  /// Calculate adjusted sets based on user level
  int getSetsForLevel(Level userLevel) {
    return (baseSets * userLevel.setMultiplier).round();
  }

  /// Calculate adjusted reps based on user level
  int getRepsForLevel(Level userLevel) {
    return (baseReps * userLevel.repMultiplier).round();
  }

  /// Calculate adjusted duration based on user's level
  int getDurationForLevel(Level userLevel) {
    return (baseDurations * userLevel.repMultiplier).round();
  }

  /// Check if this workout matches user's selected categories
  bool matchesCategories(List<Categories> userCategories) {
    return categories.any((cat) => userCategories.contains(cat));
  }

}
