import 'package:flutter/material.dart';

/// Simple responsive helper extension
extension ResponsiveExtension on BuildContext {
  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if small screen (< 360)
  bool get isSmallScreen => screenWidth < 360;

  /// Check if tablet/large screen (>= 600)
  bool get isLargeScreen => screenWidth >= 600;

  /// Get grid columns for exercise list
  int get gridColumns => screenWidth >= 600 ? 3 : 2;
}
