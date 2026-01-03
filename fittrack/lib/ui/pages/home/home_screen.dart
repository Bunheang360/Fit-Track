import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/models/exercise.dart';
import '../../../data/repositories/user_repositories.dart';
import '../../../data/repositories/exercise_repositories.dart';
import '../../../data/repositories/setting_repositories.dart';
import '../../../core/constants/enums.dart';
import '../authentication/login_screen.dart';
import '../workout/workout_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/home/progress_circle.dart';
import '../../widgets/home/workout_section_card.dart';
import '../../widgets/home/weekly_schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userRepository = UserRepository();
  final _exerciseRepository = ExerciseRepository();
  final _settingsRepository = SettingsRepository();

  User? _currentUser;
  WorkoutPlan? _workoutPlan;
  bool _isLoading = true;
  NavTab _selectedTab = NavTab.home;

  // Track completed exercises
  int _warmupCompleted = 0;
  int _mainWorkoutCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final userId = await _settingsRepository.getCurrentUserId();
      if (userId == null) {
        _logout();
        return;
      }

      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        _logout();
        return;
      }

      final workoutPlan = await _exerciseRepository.getWorkoutPlanForUser(user);

      setState(() {
        _currentUser = user;
        _workoutPlan = workoutPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _settingsRepository.setLoggedOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Error loading user data')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavBar(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case NavTab.home:
        return _buildHomePage();
      case NavTab.analytics:
        return AnalyticsScreen(userId: _currentUser!.id);
      case NavTab.settings:
        return SettingsScreen(user: _currentUser!, onLogout: _logout);
    }
  }

  /// Check if today is a workout day for the user
  bool _isTodayWorkoutDay() {
    final now = DateTime.now();
    // Convert DateTime weekday (1=Monday, 7=Sunday) to DayOfWeek enum
    final todayIndex = now.weekday - 1; // 0=Monday, 6=Sunday
    final today = DayOfWeek.values[todayIndex];
    return _currentUser!.selectedDays.contains(today);
  }

  /// Main Home Page (Frame 2)
  Widget _buildHomePage() {
    final user = _currentUser!;
    final plan = _workoutPlan;
    final warmupCount = plan?.warmupExercises.length ?? 0;
    final mainCount = plan?.mainExercises.length ?? 0;
    final isWorkoutDay = _isTodayWorkoutDay();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          // Greeting
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                const TextSpan(
                  text: 'Hello ',
                  style: TextStyle(color: Colors.orange),
                ),
                TextSpan(
                  text: '${user.name}!',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.selectedPlan.displayName} Workout Plan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          WeeklySchedule(selectedDays: user.selectedDays),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWorkoutDay ? Colors.grey[100] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isWorkoutDay
                  ? "Hello friends! Let's get you going with this workout today"
                  : "Today is your rest day! Take it easy and recover.",
              style: TextStyle(
                fontSize: 14,
                color: isWorkoutDay ? Colors.black87 : Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isWorkoutDay) ...[
            _buildTodaysProgressSection(warmupCount, mainCount),
            const SizedBox(height: 24),
            WorkoutSectionCard(
              title: 'Warm Up',
              subtitle: 'Stretching & light cardio',
              icon: Icons.directions_run,
              onStart: () => _navigateToWorkoutList(
                'Warm Up',
                plan?.warmupExercises ?? [],
              ),
            ),
            const SizedBox(height: 12),
            WorkoutSectionCard(
              title: 'Main Workout',
              subtitle: 'Full Body workout',
              icon: Icons.fitness_center,
              onStart: () => _navigateToWorkoutList(
                'Main Workout',
                plan?.mainExercises ?? [],
              ),
            ),
          ] else ...[
            _buildRestDayContent(),
          ],
        ],
      ),
    );
  }

  /// Widget shown on rest days
  Widget _buildRestDayContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.self_improvement, size: 64, color: Colors.blue[400]),
          const SizedBox(height: 16),
          const Text(
            'Rest Day',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recovery is an important part of fitness.\nStay hydrated and get good sleep!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your next workout: ${_getNextWorkoutDay()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Get the name of the next workout day
  String _getNextWorkoutDay() {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    // Check next 7 days for workout
    for (int i = 1; i <= 7; i++) {
      final checkIndex = (todayIndex + i) % 7;
      final checkDay = DayOfWeek.values[checkIndex];
      if (_currentUser!.selectedDays.contains(checkDay)) {
        return checkDay.name[0].toUpperCase() + checkDay.name.substring(1);
      }
    }
    return 'Not scheduled';
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) => Icon(
                Icons.fitness_center,
                size: 32,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'FitTrack',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedTab = NavTab.settings),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_outline, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysProgressSection(int warmupCount, int mainCount) {
    final warmupRemaining = warmupCount > 0
        ? (warmupCount - _warmupCompleted) * 2
        : 0;
    final mainRemaining = mainCount > 0
        ? (mainCount - _mainWorkoutCompleted) * 5
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: "Today's ",
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Progress',
                style: TextStyle(color: Colors.orange),
              ),
              TextSpan(
                text: ' and ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Plan',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProgressCircle(
                title: 'Warm up',
                completed: _warmupCompleted,
                total: warmupCount,
                remainingMin: warmupRemaining,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProgressCircle(
                title: 'Main Workout',
                completed: _mainWorkoutCompleted,
                total: mainCount,
                remainingMin: mainRemaining,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToWorkoutList(String title, List<Exercise> exercises) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutListScreen(
          title: title,
          exercises: exercises,
          userLevel: _currentUser!.selectedLevel,
          userId: _currentUser!.id,
          onExerciseCompleted: (exercise) {
            setState(() {
              if (title == 'Warm Up') {
                _warmupCompleted++;
              } else {
                _mainWorkoutCompleted++;
              }
            });
          },
        ),
      ),
    );
  }
}
