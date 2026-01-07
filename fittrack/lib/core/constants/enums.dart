enum GoalTier { primary, supportive, recovery }

enum Gender { male, female }

enum AnalyticsPeriod { days, weeks, months }

enum Categories {
  strength,
  endurance,
  flexibility,
  loseFat,
  getFit,
  getTaller,
  cardio,
  mobility,
  balance,
  recovery,
}

enum Plan { home, gym }

enum Level { beginner, intermediate, advanced }

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

enum WorkoutType { warmUp, mainWorkout, coolDown }

enum BodyTarget { upperBody, lowerBody, core, fullBody }

/// Navigation tabs for bottom navigation bar
enum NavTab { home, analytics, settings }

extension CategoriesExtension on Categories {
  String get displayName {
    switch (this) {
      case Categories.strength:
        return 'Strength';
      case Categories.endurance:
        return 'Endurance';
      case Categories.flexibility:
        return 'Flexibility';
      case Categories.loseFat:
        return 'Lose Fat';
      case Categories.getFit:
        return 'Get Fit';
      case Categories.getTaller:
        return 'Get Taller';
      case Categories.cardio:
        return 'Cardio';
      case Categories.mobility:
        return 'Mobility';
      case Categories.balance:
        return 'Balance';
      case Categories.recovery:
        return 'Recovery';
    }
  }

  /// Get the tier priority for this category
  GoalTier get tier {
    switch (this) {
      case Categories.loseFat:
      case Categories.strength:
      case Categories.getFit:
      case Categories.cardio:
        return GoalTier.primary;

      case Categories.endurance:
      case Categories.mobility:
      case Categories.balance:
        return GoalTier.supportive;

      case Categories.flexibility:
      case Categories.recovery:
      case Categories.getTaller:
        return GoalTier.recovery;
    }
  }
}

extension PlanExtension on Plan {
  String get displayName {
    switch (this) {
      case Plan.home:
        return 'Home Plan';
      case Plan.gym:
        return 'Gym Plan';
    }
  }
}

extension LevelExtension on Level {
  String get displayName {
    switch (this) {
      case Level.beginner:
        return 'Beginner';
      case Level.intermediate:
        return 'Intermediate';
      case Level.advanced:
        return 'Advanced';
    }
  }

  /// Get set multiplier based on level
  double get setMultiplier {
    switch (this) {
      case Level.beginner:
        return 1.0; // Base sets
      case Level.intermediate:
        return 1.3; // 30% more
      case Level.advanced:
        return 1.6; // 60% more
    }
  }

  /// Get rep multiplier based on level
  double get repMultiplier {
    switch (this) {
      case Level.beginner:
        return 0.8; // 80% of base reps
      case Level.intermediate:
        return 1.0; // Base reps
      case Level.advanced:
        return 1.2; // 20% more reps
    }
  }
}

extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
      case DayOfWeek.sunday:
        return 'Sun';
    }
  }
}

extension BodyTargetExtension on BodyTarget {
  String get displayName {
    switch (this) {
      case BodyTarget.upperBody:
        return 'Upper Body';
      case BodyTarget.lowerBody:
        return 'Lower Body';
      case BodyTarget.core:
        return 'Core';
      case BodyTarget.fullBody:
        return 'Full Body';
    }
  }
}
