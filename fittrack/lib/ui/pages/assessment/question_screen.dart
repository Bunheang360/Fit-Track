import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../../../core/constants/enums.dart';
import '../../utils/snackbar_utils.dart';
import '../home/home_screen.dart';
import '../../widgets/assessment/slider_question.dart';
import '../../widgets/assessment/single_select_question.dart';
import '../../widgets/assessment/multi_select_question.dart';

class AssessmentQuestionsScreen extends StatefulWidget {
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
  // CONTROLLERS & SERVICES
  final PageController _pageController = PageController();
  final _userService = UserService();

  // STATE VARIABLES
  int _currentPage = 0;

  /// USER ANSWERS (Assessment Data)
  int age = 25;
  Gender selectedGender = Gender.male;
  double weight = 70.0;
  double height = 170.0;
  Plan selectedPlan = Plan.home;
  Level selectedLevel = Level.beginner;
  List<Categories> selectedCategories = [];
  List<DayOfWeek> selectedDays = [];

  /// NEXT PAGE NAVIGATION
  // Validates current page and moves to next question. On last page, completes the assessment.
  void _nextPage() {
    // Validate categories page
    if (_currentPage == 5 && selectedCategories.isEmpty) {
      _showError('Please select at least one category');
      return;
    }

    // Validate schedule page
    if (_currentPage == 7 && selectedDays.isEmpty) {
      _showError('Please select at least one day');
      return;
    }

    // Go to next page or complete assessment
    if (_currentPage < 7) {
      _goToNextQuestion();
    } else {
      _completeAssessment();
    }
  }

  /// GO TO NEXT QUESTION
  void _goToNextQuestion() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// GO TO PREVIOUS PAGE
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// SHOW ERROR MESSAGE
  void _showError(String message) {
    context.showError(message);
  }

  /// SHOW SUCCESS MESSAGE
  void _showSuccess(String message) {
    context.showSuccess(message);
  }

  /// COMPLETE ASSESSMENT & SAVE USER
  // Creates user account with all assessment data and navigates to home.
  Future<void> _completeAssessment() async {
    // 1: Show loading dialog
    _showLoadingDialog();

    // 2: Create user via service
    final result = await _userService.createUser(
      username: widget.username,
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

    // 3: Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // 4: Handle result
    if (result.isSuccess) {
      _showSuccess('Profile created successfully!');
      await Future.delayed(const Duration(milliseconds: 800));
      _goToHomeScreen();
    } else {
      _showError(result.errorMessage ?? 'Failed to save profile');
    }
  }

  // SHOW LOADING DIALOG
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

  /// HOME SCREEN NAVIGATION
  void _goToHomeScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  /// CLEANUP
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildQuestionPages(),
    );
  }

  // APP BAR
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

  /// QUESTION PAGES
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
        _buildAgeQuestion(),
        _buildGenderQuestion(),
        _buildWeightQuestion(),
        _buildHeightQuestion(),
        _buildPlanQuestion(),
        _buildCategoryQuestion(),
        _buildLevelQuestion(),
        _buildScheduleQuestion(),
      ],
    );
  }

  /// 1: AGE QUESTION
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

  /// 2: GENDER QUESTION
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

  /// 3: WEIGHT QUESTION
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

  /// 4: HEIGHT QUESTION
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

  /// 5: PLAN QUESTION (HOME/GYM)
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

  /// 6: CATEGORY QUESTION
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

  /// 7: LEVEL QUESTION
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

  /// 8: SCHEDULE QUESTION
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
}
