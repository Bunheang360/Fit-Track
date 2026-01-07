import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';

class User {
  User({
    String? id,
    required this.name,
    required this.email,
    this.password,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.selectedPlan,
    required this.selectedLevel,
    required this.selectedCategories,
    required this.selectedDays,
    this.hasCompletedAssessment = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String email;
  final String? password;
  final int age;
  final Gender gender;
  final double weight;
  final double height;
  final Plan selectedPlan;
  final Level selectedLevel;
  final List<Categories> selectedCategories;
  final List<DayOfWeek> selectedDays;
  final bool hasCompletedAssessment;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender.name,
      'weight': weight,
      'height': height,
      'selectedPlan': selectedPlan.name,
      'selectedLevel': selectedLevel.name,
      'selectedCategories': selectedCategories.map((c) => c.name).toList(),
      'selectedDays': selectedDays.map((d) => d.name).toList(),
      'hasCompletedAssessment': hasCompletedAssessment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      age: json['age'] as int,
      gender: Gender.values.firstWhere((g) => g.name == json['gender']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      selectedPlan: Plan.values.firstWhere(
        (p) => p.name == json['selectedPlan'],
      ),
      selectedLevel: Level.values.firstWhere(
        (l) => l.name == json['selectedLevel'],
      ),
      selectedCategories: (json['selectedCategories'] as List)
          .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
          .toList(),
      selectedDays: (json['selectedDays'] as List)
          .map((d) => DayOfWeek.values.firstWhere((day) => day.name == d))
          .toList(),
      hasCompletedAssessment: json['hasCompletedAssessment'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Creates a copy of this User with the given fields replaced.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    int? age,
    Gender? gender,
    double? weight,
    double? height,
    Plan? selectedPlan,
    Level? selectedLevel,
    List<Categories>? selectedCategories,
    List<DayOfWeek>? selectedDays,
    bool? hasCompletedAssessment,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedCategories:
          selectedCategories ?? List.from(this.selectedCategories),
      selectedDays: selectedDays ?? List.from(this.selectedDays),
      hasCompletedAssessment:
          hasCompletedAssessment ?? this.hasCompletedAssessment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
