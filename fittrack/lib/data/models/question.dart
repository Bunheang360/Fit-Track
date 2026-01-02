import 'package:fittrack/data/models/user.dart';

import '../../core/constants/enums.dart';

class Question {
  Question({
    required this.id,
    required this.order,
    required this.type,
    required this.title,
    this.subtitle,
    this.options,
    this.minValue,
    this.maxValue,
    this.defaultValue,
    this.unit,
    this.isRequired = true,
  });

  final String id;
  final int order; // From questions 1-8
  final QuestionType type;
  final String title;
  final String? subtitle;
  final List<QuestionOption>? options; // For single/multiple choice
  final double? minValue; // For number inputs (age, weight)
  final double? maxValue;
  final dynamic defaultValue;
  final String? unit; // "Kg", "Lbs", "years", etc.
  final bool isRequired;

  /// Validate if the answer is appropriate for this question type
  bool isValidAnswer(dynamic answer) {
    switch (type) {
      case QuestionType.singleChoice:
        return answer is String && 
               options?.any((opt) => opt.value == answer) == true;
      
      case QuestionType.multipleChoice:
        return answer is List<String> && 
               answer.every((a) => options?.any((opt) => opt.value == a) == true);
      
      case QuestionType.number:
        if (answer is! num) return false;
        if (minValue != null && answer < minValue!) return false;
        if (maxValue != null && answer > maxValue!) return false;
        return true;
      
      case QuestionType.scale:
        return answer is int && 
               minValue != null && 
               maxValue != null &&
               answer >= minValue! && 
               answer <= maxValue!;
      
      default:
        return true;
    }
  }
}

class QuestionOption {
  QuestionOption({
    required this.label,
    required this.value,
    this.icon,
    this.description,
    this.relatedEnum,
  });

  final String label; // Display text: "Beginner", "Male", "Home"
  final String value; // Internal value to store
  final String? icon; // Icon path or emoji
  final String? description; // Additional info
  final dynamic relatedEnum; // Links to your existing enums
}

// User's answer to a question
class QuestionAnswer {
  QuestionAnswer({
    required this.questionId,
    required this.answer,
    required this.answeredAt,
  });

  final String questionId;
  final dynamic answer; // Can be String, List<String>, int, double
  final DateTime answeredAt;
}

// Assessment session to track user's progress
class AssessmentSession {
  AssessmentSession({
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.answers = const [],
  });

  final String userId;
  final DateTime startedAt;
  DateTime? completedAt;
  final List<QuestionAnswer> answers;

  /// Get answer for a specific question
  QuestionAnswer? getAnswer(String questionId) {
    try {
      return answers.firstWhere((a) => a.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  /// Check if assessment is complete
  bool isComplete(List<Question> allQuestions) {
    final requiredQuestions = allQuestions.where((q) => q.isRequired);
    return requiredQuestions.every(
      (q) => answers.any((a) => a.questionId == q.id)
    );
  }

  /// Calculate progress percentage
  double getProgress(List<Question> allQuestions) {
    if (allQuestions.isEmpty) return 0.0;
    return answers.length / allQuestions.length;
  }

  /// Convert answers to User model
  User toUser({
    required String name,
    required String email,
  }) {
    // Extract answers and convert to User model
    final age = (getAnswer('age')?.answer as num?)?.toInt() ?? 18;
    final gender = _parseGender(getAnswer('gender')?.answer);
    final weight = (getAnswer('weight')?.answer as num?)?.toDouble() ?? 60.0;
    final height = (getAnswer('height')?.answer as num?)?.toDouble() ?? 170.0;
    final plan = _parsePlan(getAnswer('plan')?.answer);
    final level = _parseLevel(getAnswer('level')?.answer);
    final categories = _parseCategories(getAnswer('categories')?.answer);
    final days = _parseDays(getAnswer('schedule')?.answer);

    return User(
      name: name,
      email: email,
      age: age,
      gender: gender,
      weight: weight,
      height: height,
      selectedPlan: plan,
      selectedLevel: level,
      selectedCategories: categories,
      selectedDays: days,
    );
  }

  Gender _parseGender(dynamic answer) {
    if (answer == 'male') return Gender.male;
    if (answer == 'female') return Gender.female;
    return Gender.preferNotToSay;
  }

  Plan _parsePlan(dynamic answer) {
    if (answer == 'home') return Plan.home;
    if (answer == 'gym') return Plan.gym;
    return Plan.home;
  }

  Level _parseLevel(dynamic answer) {
    if (answer == 'beginner') return Level.beginner;
    if (answer == 'intermediate') return Level.intermediate;
    if (answer == 'advanced') return Level.advanced;
    return Level.beginner;
  }

  List<Categories> _parseCategories(dynamic answer) {
    if (answer is! List) return [];
    return (answer as List<String>).map((cat) {
      switch (cat) {
        case 'get_fit': return Categories.getFit;
        case 'endurance': return Categories.endurance;
        case 'get_taller': return Categories.getTaller;
        case 'recovery': return Categories.recovery;
        case 'strength': return Categories.strength;
        case 'lose_fat': return Categories.loseFat;
        case 'flexibility': return Categories.flexibility;
        case 'balance': return Categories.balance;
        default: return Categories.getFit;
      }
    }).toList();
  }

  List<DayOfWeek> _parseDays(dynamic answer) {
    if (answer is! List) return [];
    return (answer as List<String>).map((day) {
      switch (day) {
        case 'monday': return DayOfWeek.monday;
        case 'tuesday': return DayOfWeek.tuesday;
        case 'wednesday': return DayOfWeek.wednesday;
        case 'thursday': return DayOfWeek.thursday;
        case 'friday': return DayOfWeek.friday;
        case 'saturday': return DayOfWeek.saturday;
        case 'sunday': return DayOfWeek.sunday;
        default: return DayOfWeek.monday;
      }
    }).toList();
  }
}