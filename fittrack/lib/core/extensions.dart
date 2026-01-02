import 'package:flutter/material.dart';
import '../../data/models/workout.dart';
import '../../core/constants/enums.dart';

/// Extension methods for Workout model
extension WorkoutExtensions on Workout {
  /// Get display text for sets and reps
  String getExerciseMetrics(Level userLevel) {
    final sets = getSetsForLevel(userLevel);
    final reps = getRepsForLevel(userLevel);
    return '$sets sets × $reps reps';
  }

  /// Get display text for basic metrics
  String get basicMetrics => '$baseSets sets × $baseReps reps';
}

/// Extension methods for Level enum
extension LevelExtensions on Level {
  /// Get user-friendly level name
  String get readableName {
    switch (this) {
      case Level.beginner:
        return 'Beginner';
      case Level.intermediate:
        return 'Intermediate';
      case Level.advanced:
        return 'Advanced';
    }
  }
}

/// Extension methods for Categories enum
extension CategoriesExtensions on Categories {
  /// Check if this is a warm-up focused category
  bool get isWarmupCategory {
    return this == Categories.flexibility || this == Categories.mobility;
  }
}

/// Extension methods for building UI elements
extension WidgetExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Check if screen is in landscape
  bool get isLandscape => screenSize.width > screenSize.height;
  
  /// Check if screen is small (mobile)
  bool get isSmallScreen => screenWidth < 600;
}
