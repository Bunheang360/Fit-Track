import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repositories.dart';
import '../../../data/repositories/setting_repositories.dart';
import '../../../core/constants/enums.dart';
import '../home/home_screen.dart';
// Reusable question widgets - no more 8 separate screen files!
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

class _AssessmentQuestionsScreenState
    extends State<AssessmentQuestionsScreen> {
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
      print('');
      print('🎯🎯🎯 STARTING ASSESSMENT COMPLETION 🎯🎯🎯');
      print('');

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
        hasCompletedAssessment: true, // ⭐ VERY IMPORTANT!
      );

      print('✅ User object created with ID: ${user.id}');

      // Save user to storage
      await _userRepository.saveUser(user);
      print('✅ User saved to repository');

      // Mark as logged in (use user.id instead of username)
      await _settingsRepository.setLoggedIn(user.id, widget.username);
      print('✅ Login status saved');

      // Debug: Verify save
      await _userRepository.debugPrintAllUsers();
      await _settingsRepository.debugPrintSettings();

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

      print('');
      print('✅✅✅ ASSESSMENT COMPLETED SUCCESSFULLY ✅✅✅');
      print('');
    } catch (e) {
      print('');
      print('❌❌❌ ASSESSMENT COMPLETION FAILED ❌❌❌');
      print('Error: $e');
      print('');

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
          SliderQuestion<int>(
            title: "What's your Age?",
            initialValue: age,
            minValue: 13,
            maxValue: 80,
            divisions: 67,
            formatValue: (v) => '$v',
            onValueChanged: (newAge) => setState(() => age = newAge),
            onNext: _nextPage,
          ),

          // 2. Gender - Single Select
          SingleSelectQuestion<Gender>(
            title: "What is your gender?",
            initialValue: selectedGender,
            options: [
              SelectOption(value: Gender.male, label: 'Male', icon: Icons.male),
              SelectOption(value: Gender.female, label: 'Female', icon: Icons.female),
            ],
            onValueChanged: (gender) => setState(() => selectedGender = gender),
            onNext: _nextPage,
          ),

          // 3. Weight - Slider Question
          SliderQuestion<double>(
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
          SliderQuestion<double>(
            title: "What is your height?",
            initialValue: height,
            minValue: 120.0,
            maxValue: 220.0,
            divisions: 100,
            unit: 'cm',
            formatValue: (v) => '${v.toStringAsFixed(0)} cm',
            onValueChanged: (newHeight) => setState(() => height = newHeight),
            onNext: _nextPage,
          ),

          // 5. Plan - Single Select with descriptions
          SingleSelectQuestion<Plan>(
            title: "Select your plan",
            initialValue: selectedPlan,
            showDescription: true,
            options: [
              SelectOption(
                value: Plan.home,
                label: 'Home',
                icon: Icons.home,
                description: 'Workout at home with minimal equipment',
              ),
              SelectOption(
                value: Plan.gym,
                label: 'Gym',
                icon: Icons.fitness_center,
                description: 'Access to full gym equipment',
              ),
            ],
            onValueChanged: (plan) => setState(() => selectedPlan = plan),
            onNext: _nextPage,
          ),

          // 6. Categories - Multi Select (Chips)
          MultiSelectQuestion<Categories>(
            title: "Categories",
            subtitle: "Select your fitness goals",
            initialValues: selectedCategories,
            options: Categories.values
                .map((cat) => MultiSelectOption(value: cat, label: cat.displayName))
                .toList(),
            onValuesChanged: (categories) =>
                setState(() => selectedCategories = categories),
            onNext: _nextPage,
            style: MultiSelectStyle.chips,
          ),

          // 7. Level - Single Select
          SingleSelectQuestion<Level>(
            title: "Select the level",
            initialValue: selectedLevel,
            options: [
              SelectOption(value: Level.beginner, label: 'Beginner', icon: Icons.star_border),
              SelectOption(value: Level.intermediate, label: 'Intermediate', icon: Icons.star_half),
              SelectOption(value: Level.advanced, label: 'Advanced', icon: Icons.star),
            ],
            onValueChanged: (level) => setState(() => selectedLevel = level),
            onNext: _nextPage,
          ),

          // 8. Schedule - Multi Select (Grid)
          MultiSelectQuestion<DayOfWeek>(
            title: "Select the schedule",
            subtitle: "Choose your workout days",
            initialValues: selectedDays,
            options: DayOfWeek.values
                .map((day) => MultiSelectOption(value: day, label: day.displayName))
                .toList(),
            onValuesChanged: (days) => setState(() => selectedDays = days),
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
