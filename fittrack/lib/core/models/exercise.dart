import '../../core/constants/enums.dart';
import 'package:uuid/uuid.dart';

class Exercise {
  Exercise({
    String? id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.categories,
    required this.plan,
    required this.bodyTarget,
    required this.sectionType,
    required this.baseSets,
    required this.baseReps,
    required this.baseDuration,
    required this.restPeriod,
    required this.instructions,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Categories> categories;
  final Plan plan;
  final BodyTarget bodyTarget;
  final WorkoutType sectionType;
  final int baseSets;
  final int baseReps;
  final int baseDuration;
  final int restPeriod;
  final List<String> instructions;

  /// Get adjusted sets for user level
  int getSetsForLevel(Level userLevel) {
    return (baseSets * userLevel.setMultiplier).round();
  }

  /// Get adjusted reps for user level
  int getRepsForLevel(Level userLevel) {
    return (baseReps * userLevel.repMultiplier).round();
  }

  /// Get adjusted duration for user level
  int getDurationForLevel(Level userLevel) {
    return (baseDuration * userLevel.repMultiplier).round();
  }

  /// Check if matches user's categories
  bool matchesCategories(List<Categories> userCategories) {
    return categories.any((cat) => userCategories.contains(cat));
  }

  /// Check if matches user's plan
  bool matchesPlan(Plan userPlan) {
    return plan == userPlan;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories.map((c) => c.name).toList(),
      'plan': plan.name,
      'bodyTarget': bodyTarget.name,
      'sectionType': sectionType.name,
      'baseSets': baseSets,
      'baseReps': baseReps,
      'baseDuration': baseDuration,
      'restPeriod': restPeriod,
      'instructions': instructions,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      categories: (json['categories'] as List)
          .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
          .toList(),
      plan: Plan.values.firstWhere((p) => p.name == json['plan']),
      bodyTarget: BodyTarget.values.firstWhere(
        (b) => b.name == json['bodyTarget'],
      ),
      sectionType: WorkoutType.values.firstWhere(
        (s) => s.name == json['sectionType'],
      ),
      baseSets: json['baseSets'] as int,
      baseReps: json['baseReps'] as int,
      baseDuration: json['baseDuration'] as int,
      restPeriod: json['restPeriod'] as int,
      instructions: List<String>.from(json['instructions'] as List),
    );
  }
}
