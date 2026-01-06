import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/models/exercise.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/constants/enums.dart';
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
  // ==========================================
  // REPOSITORIES (for database access)
  // ==========================================
  final _userRepository = UserRepository();
  final _exerciseRepository = ExerciseRepository();
  final _settingsRepository = SettingsRepository();
  final _sessionRepository = SessionRepository();

  // ==========================================
  // STATE VARIABLES
  // ==========================================
  User? _currentUser; // The logged-in user's data
  WorkoutPlan? _workoutPlan; // Today's workout exercises
  bool _isLoading = true; // Shows loading spinner when true
  NavTab _selectedTab = NavTab.home; // Current bottom nav tab

  // Track which exercises have been completed today
  // Using Set<String> ensures no duplicates (each exercise ID only once)
  final Set<String> _completedWarmupIds = {};
  final Set<String> _completedMainWorkoutIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ==========================================
  // LOAD USER DATA FROM DATABASE
  // ==========================================
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Step 1: Get the current user's ID from settings
      final userId = await _settingsRepository.getCurrentUserId();
      if (userId == null) {
        _logout(); // No user ID means not logged in
        return;
      }

      // Step 2: Get the user's full data from database
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        _logout(); // User not found in database
        return;
      }

      // Step 3: Get the workout plan based on user's preferences
      final workoutPlan = await _exerciseRepository.getWorkoutPlanForUser(user);

      // Step 4: Load today's completed exercises from database
      await _loadTodaysProgress(userId, workoutPlan);

      // Step 5: Update the screen with loaded data
      setState(() {
        _currentUser = user;
        _workoutPlan = workoutPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // LOAD TODAY'S COMPLETED EXERCISES
  // ==========================================
  /// This method loads exercises the user already completed today.
  /// This ensures progress is saved even if user logs out and back in.
  Future<void> _loadTodaysProgress(
    String userId,
    WorkoutPlan? workoutPlan,
  ) async {
    if (workoutPlan == null) return;

    // Step 1: Get all exercise sessions from today
    final todaySessions = await _sessionRepository.getTodaySessions(userId);

    // Step 2: Create lists of warmup and main workout exercise IDs
    List<String> warmupIds = [];
    for (final exercise in workoutPlan.warmupExercises) {
      warmupIds.add(exercise.id);
    }

    List<String> mainIds = [];
    for (final exercise in workoutPlan.mainExercises) {
      mainIds.add(exercise.id);
    }

    // Step 3: Clear old completed data
    _completedWarmupIds.clear();
    _completedMainWorkoutIds.clear();

    // Step 4: Check each session and mark as completed
    for (final session in todaySessions) {
      if (warmupIds.contains(session.exerciseId)) {
        _completedWarmupIds.add(session.exerciseId);
      } else if (mainIds.contains(session.exerciseId)) {
        _completedMainWorkoutIds.add(session.exerciseId);
      }
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
        return SettingsScreen(
          user: _currentUser!,
          onLogout: _logout,
          onEditPlan: _navigateToEditPlan,
          onChangePassword: _navigateToChangePassword,
          onEditProfile: _navigateToEditProfile,
        );
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
              style: TextStyle(fontSize: isSmall ? 20 : 24, fontWeight: FontWeight.bold),
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
              color: isWorkoutDay ? Colors.grey[100] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isWorkoutDay
                  ? "Hello friends! Let's get you going with this workout today"
                  : "Today is your rest day! Take it easy and recover.",
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                color: isWorkoutDay ? Colors.black87 : Colors.blue[800],
              ),
            ),
          ),
          SizedBox(height: isSmall ? 20 : 24),
          if (isWorkoutDay) ...[
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
    // Calculate completed counts from sets (not exceeding total)
    final warmupCompleted = _completedWarmupIds.length;
    final mainCompleted = _completedMainWorkoutIds.length;

    final warmupRemaining = warmupCount > 0
        ? (warmupCount - warmupCompleted) * 2
        : 0;
    final mainRemaining = mainCount > 0 ? (mainCount - mainCompleted) * 5 : 0;

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
                completed: warmupCompleted,
                total: warmupCount,
                remainingMin: warmupRemaining,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProgressCircle(
                title: 'Main Workout',
                completed: mainCompleted,
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

  // ==========================================
  // NAVIGATE TO WORKOUT LIST
  // ==========================================
  /// Opens the workout list screen for warmup or main workout.
  /// Only shows exercises that haven't been completed yet today.
  void _navigateToWorkoutList(String title, List<Exercise> exercises) {
    // Step 1: Get completed exercise IDs based on workout type
    Set<String> completedIds;
    if (title == 'Warm Up') {
      completedIds = _completedWarmupIds;
    } else {
      completedIds = _completedMainWorkoutIds;
    }

    // Step 2: Filter out completed exercises
    List<Exercise> remainingExercises = [];
    for (final exercise in exercises) {
      if (!completedIds.contains(exercise.id)) {
        remainingExercises.add(exercise);
      }
    }

    // Step 3: If all done, show message and return
    if (remainingExercises.isEmpty) {
      _showCompletedMessage(title);
      return;
    }

    // Step 4: Navigate to workout list
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
        ),
      ),
    );
  }

  // ==========================================
  // HANDLE EXERCISE COMPLETION
  // ==========================================
  void _onExerciseCompleted(String workoutType, Exercise exercise) {
    setState(() {
      if (workoutType == 'Warm Up') {
        _completedWarmupIds.add(exercise.id);
      } else {
        _completedMainWorkoutIds.add(exercise.id);
      }
    });
  }

  // ==========================================
  // SHOW COMPLETED MESSAGE
  // ==========================================
  void _showCompletedMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title already completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
