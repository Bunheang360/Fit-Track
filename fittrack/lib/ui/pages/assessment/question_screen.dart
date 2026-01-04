import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/constants/enums.dart';
import '../home/home_screen.dart';
import '../../widgets/assessment/slider_question.dart';
import '../../widgets/assessment/single_select_question.dart';
import '../../widgets/assessment/multi_select_question.dart';

class AssessmentQuestionsScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const AssessmentQuestionsScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<AssessmentQuestionsScreen> createState() =>
      _AssessmentQuestionsScreenState();
}

class _AssessmentQuestionsScreenState extends State<AssessmentQuestionsScreen> {
  final PageController _pageController = PageController();
  final _userRepository = UserRepository();
  final _settingsRepository = SettingsRepository();

  int _currentPage = 0;

  // Assessment answers
  int age = 25;
  Gender selectedGender = Gender.male;
  double weight = 70.0;
  double height = 170.0;
  Plan selectedPlan = Plan.home;
  Level selectedLevel = Level.beginner;
  List<Categories> selectedCategories = [];
  List<DayOfWeek> selectedDays = [];

  void _nextPage() {
    // Validate current page
    if (_currentPage == 5 && selectedCategories.isEmpty) {
      _showError('Please select at least one category');
      return;
    }

    if (_currentPage == 7 && selectedDays.isEmpty) {
      _showError('Please select at least one day');
      return;
    }

    if (_currentPage < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAssessment();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _completeAssessment() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );

      // Create User object with all assessment data
      final user = User(
        name: widget.username,
        email: widget.email,
        password: widget.password,
        age: age,
        gender: selectedGender,
        weight: weight,
        height: height,
        selectedPlan: selectedPlan,
        selectedLevel: selectedLevel,
        selectedCategories: selectedCategories,
        selectedDays: selectedDays,
        hasCompletedAssessment: true,
      );

      // Save user to storage
      await _userRepository.saveUser(user);

      // Mark as logged in
      await _settingsRepository.setLoggedIn(user.id, widget.username);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      _showSuccess('Profile created successfully!');

      // Small delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      _showError('Failed to save profile. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Assessment ${_currentPage + 1}/8',
          style: const TextStyle(color: Colors.white),
        ),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // 1. Age - Slider Question
          SliderQuestion(
            title: "What's your Age?",
            initialValue: age.toDouble(),
            minValue: 13,
            maxValue: 80,
            divisions: 67,
            showAsInteger: true,
            onValueChanged: (newAge) => setState(() => age = newAge.toInt()),
            onNext: _nextPage,
          ),

          // 2. Gender - Single Select
          SingleSelectQuestion(
            title: "What is your gender?",
            initialValue: selectedGender.name,
            options: [
              SelectOption(value: 'male', label: 'Male', icon: Icons.male),
              SelectOption(
                value: 'female',
                label: 'Female',
                icon: Icons.female,
              ),
            ],
            onValueChanged: (gender) => setState(() {
              selectedGender = Gender.values.firstWhere(
                (g) => g.name == gender,
              );
            }),
            onNext: _nextPage,
          ),

          // 3. Weight - Slider Question
          SliderQuestion(
            title: "What's your current\nweight right now?",
            initialValue: weight,
            minValue: 30.0,
            maxValue: 150.0,
            divisions: 240,
            unit: 'Kg',
            onValueChanged: (newWeight) => setState(() => weight = newWeight),
            onNext: _nextPage,
          ),

          // 4. Height - Slider Question
          SliderQuestion(
            title: "What is your height?",
            initialValue: height,
            minValue: 120.0,
            maxValue: 220.0,
            divisions: 100,
            unit: 'cm',
            showAsInteger: true,
            onValueChanged: (newHeight) => setState(() => height = newHeight),
            onNext: _nextPage,
          ),

          // 5. Plan - Single Select with descriptions
          SingleSelectQuestion(
            title: "Select your plan",
            initialValue: selectedPlan.name,
            showDescription: true,
            options: [
              SelectOption(
                value: 'home',
                label: 'Home',
                icon: Icons.home,
                description: 'Workout at home with minimal equipment',
              ),
              SelectOption(
                value: 'gym',
                label: 'Gym',
                icon: Icons.fitness_center,
                description: 'Access to full gym equipment',
              ),
            ],
            onValueChanged: (plan) => setState(() {
              selectedPlan = Plan.values.firstWhere((p) => p.name == plan);
            }),
            onNext: _nextPage,
          ),

          // 6. Categories - Multi Select (Chips)
          MultiSelectQuestion(
            title: "Categories",
            subtitle: "Select your fitness goals",
            initialValues: selectedCategories.map((cat) => cat.name).toList(),
            options: Categories.values
                .map(
                  (cat) => MultiSelectOption(
                    value: cat.name,
                    label: cat.displayName,
                  ),
                )
                .toList(),
            onValuesChanged: (categories) => setState(() {
              selectedCategories = categories
                  .map(
                    (name) =>
                        Categories.values.firstWhere((c) => c.name == name),
                  )
                  .toList();
            }),
            onNext: _nextPage,
            style: MultiSelectStyle.chips,
          ),

          // 7. Level - Single Select
          SingleSelectQuestion(
            title: "Select the level",
            initialValue: selectedLevel.name,
            options: [
              SelectOption(
                value: 'beginner',
                label: 'Beginner',
                icon: Icons.star_border,
              ),
              SelectOption(
                value: 'intermediate',
                label: 'Intermediate',
                icon: Icons.star_half,
              ),
              SelectOption(
                value: 'advanced',
                label: 'Advanced',
                icon: Icons.star,
              ),
            ],
            onValueChanged: (level) => setState(() {
              selectedLevel = Level.values.firstWhere((l) => l.name == level);
            }),
            onNext: _nextPage,
          ),

          // 8. Schedule - Multi Select (Grid)
          MultiSelectQuestion(
            title: "Select the schedule",
            subtitle: "Choose your workout days",
            initialValues: selectedDays.map((day) => day.name).toList(),
            options: DayOfWeek.values
                .map(
                  (day) => MultiSelectOption(
                    value: day.name,
                    label: day.displayName,
                  ),
                )
                .toList(),
            onValuesChanged: (days) => setState(() {
              selectedDays = days
                  .map(
                    (name) =>
                        DayOfWeek.values.firstWhere((d) => d.name == name),
                  )
                  .toList();
            }),
            onNext: _nextPage,
            isLastPage: true,
            style: MultiSelectStyle.grid,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
