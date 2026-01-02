import 'package:flutter/material.dart';

/// Constants for the home screen UI
class HomeScreenConstants {
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 28.0;
  
  // Margins and spacing
  static const EdgeInsets standardPadding = EdgeInsets.all(defaultPadding);
  static const SizedBox verticalSpacing16 = SizedBox(height: 16);
  static const SizedBox verticalSpacing12 = SizedBox(height: 12);
  static const SizedBox verticalSpacing32 = SizedBox(height: 32);
  static const SizedBox horizontalSpacing12 = SizedBox(width: 12);
  
  // Exercise limits
  static const int warmupExerciseLimit = 2;
  static const int mainWorkoutLimit = 4;
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 12.0;
  
  // Card dimensions
  static const double horizontalCardWidth = 140.0;
  static const double horizontalCardHeight = 180.0;
  
  // Colors
  static const Color primaryBackgroundColor = Colors.white;
  static const Color textPrimaryColor = Colors.black;
  
  // Duration
  static const Duration navigationDuration = Duration(milliseconds: 300);
}

/// Constants for workout detail screen
class WorkoutDetailConstants {
  static const double expandedHeight = 250.0;
  static const double setStatFontSize = 20.0;
  static const double labelFontSize = 12.0;
}

/// Constants for typography
class TextStyles {
  static const TextStyle heading18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading28 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle subtitle14 = TextStyle(
    fontSize: 14,
  );
  
  static const TextStyle body14 = TextStyle(
    fontSize: 14,
    height: 1.6,
  );
}
