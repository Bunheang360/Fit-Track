import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repositories.dart';
import '../../../data/repositories/setting_repositories.dart';
import '../../../core/constants/enums.dart';
import '../../start_screen.dart';
import 'screens/age_page.dart';
import 'screens/categories_page.dart';
import 'screens/gender_page.dart';
import 'screens/height_page.dart';
import 'screens/level_page.dart';
import 'screens/plan_page.dart';
import 'screens/schedule_page.dart';
import 'screens/weight_page.dart';

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
    // Validate current page before moving forward
    if (_currentPage == 5 && selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPage == 7 && selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.red,
        ),
      );
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

  void _completeAssessment() {
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
    );

    // Save user to storage
    final userRepository = UserRepository();
    userRepository.saveUser(user); // Pass User object, not JSON!

    // Mark as logged in
    final settingsRepository = SettingsRepository();
    settingsRepository.setLoggedIn(widget.username);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
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
          AgePage(
            initialAge: age,
            onAgeChanged: (value) => setState(() => age = value),
            onNext: _nextPage,
          ),
          GenderPage(
            initialGender: selectedGender,
            onGenderChanged: (value) => setState(() => selectedGender = value),
            onNext: _nextPage,
          ),
          WeightPage(
            initialWeight: weight,
            onWeightChanged: (value) => setState(() => weight = value),
            onNext: _nextPage,
          ),
          HeightPage(
            initialHeight: height,
            onHeightChanged: (value) => setState(() => height = value),
            onNext: _nextPage,
          ),
          PlanPage(
            initialPlan: selectedPlan,
            onPlanChanged: (value) => setState(() => selectedPlan = value),
            onNext: _nextPage,
          ),
          CategoriesPage(
            initialCategories: selectedCategories,
            onCategoriesChanged: (value) =>
                setState(() => selectedCategories = value),
            onNext: _nextPage,
          ),
          LevelPage(
            initialLevel: selectedLevel,
            onLevelChanged: (value) => setState(() => selectedLevel = value),
            onNext: _nextPage,
          ),
          SchedulePage(
            initialDays: selectedDays,
            onDaysChanged: (value) => setState(() => selectedDays = value),
            onNext: _nextPage,
          ),
        ],
      ),
    );
  }
}
