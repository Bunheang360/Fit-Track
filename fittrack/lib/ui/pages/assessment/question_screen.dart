import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../core/constants/enums.dart';
import '../home/home_screen.dart';
import '../../widgets/assessment/slider_question.dart';
import '../../widgets/assessment/single_select_question.dart';
import '../../widgets/assessment/multi_select_question.dart';

// ============================================================================
// ASSESSMENT QUESTIONS SCREEN
// ============================================================================
/// This screen shows 8 questions to collect user fitness data:
/// 1. Age (slider)
/// 2. Gender (single select)
/// 3. Weight (slider)
/// 4. Height (slider)
/// 5. Plan - Home/Gym (single select)
/// 6. Categories - Abs/Arms/etc (multi select)
/// 7. Level - Beginner/Intermediate/Advanced (single select)
/// 8. Schedule - Mon-Sun (multi select)
class AssessmentQuestionsScreen extends StatefulWidget {
  // ==========================================
  // CONSTRUCTOR PARAMETERS
  // ==========================================
  /// User credentials from signup screen
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
  // ==========================================
  // CONTROLLERS & REPOSITORIES
  // ==========================================
  final PageController _pageController = PageController();
  final _userRepository = UserRepository();
  final _settingsRepository = SettingsRepository();

  // ==========================================
  // STATE VARIABLES
  // ==========================================
  int _currentPage = 0;

  // ==========================================
  // USER ANSWERS (Assessment Data)
  // ==========================================
  int age = 25;
  Gender selectedGender = Gender.male;
  double weight = 70.0;
  double height = 170.0;
  Plan selectedPlan = Plan.home;
  Level selectedLevel = Level.beginner;
  List<Categories> selectedCategories = [];
  List<DayOfWeek> selectedDays = [];

  // ==========================================
  // GO TO NEXT PAGE
  // ==========================================
  /// Validates current page and moves to next question.
  /// On last page, completes the assessment.
  void _nextPage() {
    // Step 1: Validate categories page
    if (_currentPage == 5 && selectedCategories.isEmpty) {
      _showError('Please select at least one category');
      return;
    }

    // Step 2: Validate schedule page
    if (_currentPage == 7 && selectedDays.isEmpty) {
      _showError('Please select at least one day');
      return;
    }

    // Step 3: Go to next page or complete assessment
    if (_currentPage < 7) {
      _goToNextQuestion();
    } else {
      _completeAssessment();
    }
  }

  // ==========================================
  // GO TO NEXT QUESTION (ANIMATE)
  // ==========================================
  void _goToNextQuestion() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================================
  // GO TO PREVIOUS PAGE
  // ==========================================
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ==========================================
  // SHOW ERROR MESSAGE
  // ==========================================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // SHOW SUCCESS MESSAGE
  // ==========================================
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // COMPLETE ASSESSMENT & SAVE USER
  // ==========================================
  /// Creates user account with all assessment data and navigates to home.
  Future<void> _completeAssessment() async {
    try {
      // Step 1: Show loading dialog
      _showLoadingDialog();

      // Step 2: Create user with assessment data
      final user = _createUserFromAssessment();

      // Step 3: Save user to database
      await _userRepository.saveUser(user);

      // Step 4: Mark as logged in
      await _settingsRepository.setLoggedIn(user.id, widget.username);

      // Step 5: Close loading and show success
      if (mounted) Navigator.of(context).pop();
      _showSuccess('Profile created successfully!');

      // Step 6: Navigate to home screen
      await Future.delayed(const Duration(milliseconds: 800));
      _goToHomeScreen();
    } catch (e) {
      // If error, close loading and show error
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to save profile. Please try again.');
    }
  }

  // ==========================================
  // SHOW LOADING DIALOG
  // ==========================================
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
  }

  // ==========================================
  // CREATE USER FROM ASSESSMENT DATA
  // ==========================================
  User _createUserFromAssessment() {
    return User(
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
  }

  // ==========================================
  // GO TO HOME SCREEN
  // ==========================================
  void _goToHomeScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // ==========================================
  // BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildQuestionPages(),
    );
  }

  // ==========================================
  // BUILD APP BAR
  // ==========================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Assessment ${_currentPage + 1}/8',
        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600),
      ),
      leading: _currentPage > 0
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
              onPressed: _previousPage,
            )
          : null,
    );
  }

  // ==========================================
  // BUILD QUESTION PAGES
  // ==========================================
  Widget _buildQuestionPages() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        _buildAgeQuestion(), // Page 1
        _buildGenderQuestion(), // Page 2
        _buildWeightQuestion(), // Page 3
        _buildHeightQuestion(), // Page 4
        _buildPlanQuestion(), // Page 5
        _buildCategoryQuestion(), // Page 6
        _buildLevelQuestion(), // Page 7
        _buildScheduleQuestion(), // Page 8
      ],
    );
  }

  // ==========================================
  // PAGE 1: AGE QUESTION
  // ==========================================
  Widget _buildAgeQuestion() {
    return SliderQuestion(
      title: "What's your Age?",
      initialValue: age.toDouble(),
      minValue: 13,
      maxValue: 80,
      divisions: 67,
      showAsInteger: true,
      onValueChanged: (newAge) => setState(() => age = newAge.toInt()),
      onNext: _nextPage,
    );
  }

  // ==========================================
  // PAGE 2: GENDER QUESTION
  // ==========================================
  Widget _buildGenderQuestion() {
    return SingleSelectQuestion(
      title: "What is your gender?",
      initialValue: selectedGender.name,
      options: [
        SelectOption(value: 'male', label: 'Male', icon: Icons.male),
        SelectOption(value: 'female', label: 'Female', icon: Icons.female),
      ],
      onValueChanged: (gender) => setState(() {
        selectedGender = Gender.values.firstWhere((g) => g.name == gender);
      }),
      onNext: _nextPage,
    );
  }

  // ==========================================
  // PAGE 3: WEIGHT QUESTION
  // ==========================================
  Widget _buildWeightQuestion() {
    return SliderQuestion(
      title: "What's your current\nweight right now?",
      initialValue: weight,
      minValue: 30.0,
      maxValue: 150.0,
      divisions: 240,
      unit: 'Kg',
      onValueChanged: (newWeight) => setState(() => weight = newWeight),
      onNext: _nextPage,
    );
  }

  // ==========================================
  // PAGE 4: HEIGHT QUESTION
  // ==========================================
  Widget _buildHeightQuestion() {
    return SliderQuestion(
      title: "What is your height?",
      initialValue: height,
      minValue: 120.0,
      maxValue: 220.0,
      divisions: 100,
      unit: 'cm',
      showAsInteger: true,
      onValueChanged: (newHeight) => setState(() => height = newHeight),
      onNext: _nextPage,
    );
  }

  // ==========================================
  // PAGE 5: PLAN QUESTION (HOME/GYM)
  // ==========================================
  Widget _buildPlanQuestion() {
    return SingleSelectQuestion(
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
    );
  }

  // ==========================================
  // PAGE 6: CATEGORY QUESTION
  // ==========================================
  Widget _buildCategoryQuestion() {
    // Build category options list
    List<MultiSelectOption> categoryOptions = [];
    for (final cat in Categories.values) {
      categoryOptions.add(
        MultiSelectOption(value: cat.name, label: cat.displayName),
      );
    }

    // Build initial values list
    List<String> initialCategoryValues = [];
    for (final cat in selectedCategories) {
      initialCategoryValues.add(cat.name);
    }

    return MultiSelectQuestion(
      title: "Categories",
      subtitle: "Select your fitness goals",
      initialValues: initialCategoryValues,
      options: categoryOptions,
      onValuesChanged: (categories) => setState(() {
        selectedCategories = [];
        for (final name in categories) {
          selectedCategories.add(
            Categories.values.firstWhere((c) => c.name == name),
          );
        }
      }),
      onNext: _nextPage,
      style: MultiSelectStyle.chips,
    );
  }

  // ==========================================
  // PAGE 7: LEVEL QUESTION
  // ==========================================
  Widget _buildLevelQuestion() {
    return SingleSelectQuestion(
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
        SelectOption(value: 'advanced', label: 'Advanced', icon: Icons.star),
      ],
      onValueChanged: (level) => setState(() {
        selectedLevel = Level.values.firstWhere((l) => l.name == level);
      }),
      onNext: _nextPage,
    );
  }

  // ==========================================
  // PAGE 8: SCHEDULE QUESTION
  // ==========================================
  Widget _buildScheduleQuestion() {
    // Build day options list
    List<MultiSelectOption> dayOptions = [];
    for (final day in DayOfWeek.values) {
      dayOptions.add(
        MultiSelectOption(value: day.name, label: day.displayName),
      );
    }

    // Build initial values list
    List<String> initialDayValues = [];
    for (final day in selectedDays) {
      initialDayValues.add(day.name);
    }

    return MultiSelectQuestion(
      title: "Select the schedule",
      subtitle: "Choose your workout days",
      initialValues: initialDayValues,
      options: dayOptions,
      onValuesChanged: (days) => setState(() {
        selectedDays = [];
        for (final name in days) {
          selectedDays.add(DayOfWeek.values.firstWhere((d) => d.name == name));
        }
      }),
      onNext: _nextPage,
      isLastPage: true,
      style: MultiSelectStyle.grid,
    );
  }

  // ==========================================
  // CLEANUP
  // ==========================================
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
