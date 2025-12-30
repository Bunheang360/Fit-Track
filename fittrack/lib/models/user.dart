import 'package:uuid/uuid.dart';
import '../constants/enums.dart';

class User {
  User({
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.selectedPlan,
    required this.selectedLevel,
    required this.selectedCategories,
    required this.selectedDays,
    this.workoutPlanId,
  }) {
    id = const Uuid().v4();
  }

  late final String id;
  String name;
  String email;
  final int age;
  final Gender gender;
  final double weight;
  final double height;
  final Plan selectedPlan;
  final Level selectedLevel;
  final List<Categories> selectedCategories;
  final List<DayOfWeek> selectedDays;
  String? workoutPlanId;
}
