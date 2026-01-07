import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/models/exercise.dart';
import '../../../services/workout_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/enums.dart';
import '../../utils/snackbar_utils.dart';
import '../authentication/login_screen.dart';
import '../workout/workout_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/edit_plan_screen.dart';
import '../settings/change_password_screen.dart';
import '../settings/edit_profile_screen.dart';
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
  // SERVICES
  final _workoutService = WorkoutService();
  final _authService = AuthService();

  // STATE VARIABLES
  User? _currentUser;
  WorkoutPlan? _workoutPlan;
  bool _isLoading = true;
  NavTab _selectedTab = NavTab.home;
  bool _isWorkoutDay = true;

  // Track which exercises have been completed today
  // Using Set<String> ensures no duplicates (each exercise ID only once)
  Set<String> _completedWarmupIds = {};
  Set<String> _completedMainWorkoutIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // LOAD USER DATA VIA SERVICE
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Load all home screen data through service
      final data = await _workoutService.loadHomeScreenData();

      if (data == null) {
        _logout();
        return;
      }

      setState(() {
        _currentUser = data.user;
        _workoutPlan = data.workoutPlan;
        _completedWarmupIds = data.completedWarmupIds;
        _completedMainWorkoutIds = data.completedMainWorkoutIds;
        _isWorkoutDay = data.isWorkoutDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          user: _currentUser!,
          onSave: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
        ),
      ),
    );
  }

  void _navigateToEditPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlanScreen(
          user: _currentUser!,
          onSave: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
            // Reload workout plan with updated categories
            _loadUserData();
          },
        ),
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(
          user: _currentUser!,
          onPasswordChanged: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
        ),
      ),
    );
  }

  /// NAVIGATE TO WORKOUT LIST
  // Opens the workout list screen for warmup or main workout.
  // Only shows exercises that haven't been completed yet today.
  // Checks if goal is already reached before navigating.
  void _navigateToWorkoutList(String title, List<Exercise> exercises) {
    // Get goal and completed count based on workout type
    final isWarmup = title == 'Warm Up';
    final completedIds = isWarmup
        ? _completedWarmupIds
        : _completedMainWorkoutIds;
    final goal = isWarmup
        ? WorkoutPlan.warmupGoal
        : WorkoutPlan.mainWorkoutGoal;
    final completedCount = completedIds.length;

    // Check if goal is already reached
    if (completedCount >= goal) {
      _showGoalCompletedMessage(title, goal);
      return;
    }

    // Filter out completed exercises
    final remainingExercises = exercises
        .where((e) => !completedIds.contains(e.id))
        .toList();

    // Calculate how many more exercises needed
    final exercisesNeeded = goal - completedCount;

    // If no remaining exercises available
    if (remainingExercises.isEmpty) {
      _showNoExercisesMessage(title);
      return;
    }

    // Navigate to workout list with info about remaining goal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutListScreen(
          title: title,
          exercises: remainingExercises,
          userLevel: _currentUser!.selectedLevel,
          userId: _currentUser!.id,
          onExerciseCompleted: (exercise) =>
              _onExerciseCompleted(title, exercise),
          goalRemaining: exercisesNeeded, // Pass remaining goal
          goalTotal: goal, // Pass total goal
        ),
      ),
    );
  }

  // HANDLE EXERCISE COMPLETION
  void _onExerciseCompleted(String workoutType, Exercise exercise) {
    setState(() {
      if (workoutType == 'Warm Up') {
        _completedWarmupIds.add(exercise.id);
      } else {
        _completedMainWorkoutIds.add(exercise.id);
      }
    });
  }

  // SHOW GOAL COMPLETED MESSAGE
  void _showGoalCompletedMessage(String title, int goal) {
    context.showSuccess('$title goal ($goal exercises) already completed! 🎉');
  }

  // SHOW NO EXERCISES MESSAGE
  void _showNoExercisesMessage(String title) {
    context.showInfo('No more $title exercises available.');
  }

  Future<void> _logout() async {
    await _authService.logout();
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
        return SettingsScreen(
          user: _currentUser!,
          onLogout: _logout,
          onEditPlan: _navigateToEditPlan,
          onChangePassword: _navigateToChangePassword,
          onEditProfile: _navigateToEditProfile,
        );
    }
  }

  Widget _buildHomePage() {
    final user = _currentUser!;
    final plan = _workoutPlan;
    final warmupCount = plan?.warmupExercises.length ?? 0;
    final mainCount = plan?.mainExercises.length ?? 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final padding = isSmall ? 16.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: isSmall ? 16 : 20),
          // Greeting
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
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
          SizedBox(height: isSmall ? 6 : 8),
          Text(
            '${user.selectedPlan.displayName} Workout Plan',
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmall ? 20 : 24),
          WeeklySchedule(selectedDays: user.selectedDays),
          SizedBox(height: isSmall ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              color: _isWorkoutDay ? Colors.grey[100] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isWorkoutDay
                  ? "Hello friends! Let's get you going with this workout today"
                  : "Today is your rest day! Take it easy and recover.",
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: _isWorkoutDay ? Colors.black87 : Colors.blue[800],
              ),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 24),
          if (_isWorkoutDay) ...[
            _buildTodaysProgressSection(warmupCount, mainCount),
            SizedBox(height: isSmall ? 20 : 24),
            WorkoutSectionCard(
              title: 'Warm Up',
              subtitle: 'Stretching & light cardio',
              icon: Icons.directions_run,
              onStart: () => _navigateToWorkoutList(
                'Warm Up',
                plan?.warmupExercises ?? [],
              ),
            ),
            SizedBox(height: isSmall ? 10 : 12),
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

  // Widget shown on rest days
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

  // Get the name of the next workout day
  String _getNextWorkoutDay() {
    return _workoutService.getNextWorkoutDay(_currentUser!);
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
    // Use goal-based progress from workout service
    final data = HomeScreenData(
      user: _currentUser!,
      workoutPlan: _workoutPlan!,
      completedWarmupIds: _completedWarmupIds,
      completedMainWorkoutIds: _completedMainWorkoutIds,
      isWorkoutDay: _isWorkoutDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with body target indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            // Body target badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Text(
                data.todaysBodyTarget,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProgressCircle(
                title: 'Warm up',
                completed: data.warmupCompleted,
                total: data.warmupGoal, // Use goal instead of total available
                remainingMin: data.warmupRemainingMinutes,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProgressCircle(
                title: 'Main Workout',
                completed: data.mainWorkoutCompleted,
                total:
                    data.mainWorkoutGoal, // Use goal instead of total available
                remainingMin: data.mainWorkoutRemainingMinutes,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        // Show completion status
        if (data.isDailyGoalComplete) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  "Daily goals complete! Great job! 🎉",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
