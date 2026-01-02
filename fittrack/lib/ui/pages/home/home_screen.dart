import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/models/exercise.dart';
import '../../../data/repositories/user_repositories.dart';
import '../../../data/repositories/exercise_repositories.dart';
import '../../../data/repositories/setting_repositories.dart';
import '../../../core/constants/enums.dart';
import '../authentication/login_screen.dart';

/// Frame 2 - Main Home Screen
/// Matches the Figma design with:
/// - FitTrack logo & greeting
/// - Weekly schedule (1-7 days)
/// - Today's Progress (Warm up / Main Workout circles)
/// - Workout sections with Start buttons
/// - Bottom navigation
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
  int _selectedNavIndex = 0;

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
      print('❌ Error loading user data: $e');
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildAnalyticPage();
      case 2:
        return _buildSettingPage();
      default:
        return _buildHomePage();
    }
  }

  /// Main Home Page (Frame 2)
  Widget _buildHomePage() {
    final user = _currentUser!;
    final plan = _workoutPlan;
    final warmupCount = plan?.warmupExercises.length ?? 0;
    final mainCount = plan?.mainExercises.length ?? 0;

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
          _buildWeeklySchedule(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Hello friends! Let's get you going with this workout today",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
          _buildTodaysProgress(warmupCount, mainCount),
          const SizedBox(height: 24),
          _buildWorkoutSection(
            title: 'Warm Up',
            subtitle: 'Stretching & light cardio',
            icon: Icons.directions_run,
            onStart: () =>
                _navigateToWorkoutList('Warm Up', plan?.warmupExercises ?? []),
          ),
          const SizedBox(height: 12),
          _buildWorkoutSection(
            title: 'Main Workout',
            subtitle: 'Full Body workout',
            icon: Icons.fitness_center,
            onStart: () => _navigateToWorkoutList(
              'Main Workout',
              plan?.mainExercises ?? [],
            ),
          ),
        ],
      ),
    );
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
          onTap: () => setState(() => _selectedNavIndex = 2),
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

  Widget _buildWeeklySchedule() {
    final user = _currentUser!;
    final today = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final dayEnum = DayOfWeek.values[index];
              final isSelected = user.selectedDays.contains(dayEnum);
              final isToday = today == dayNumber;

              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.orange
                      : isSelected
                      ? Colors.orange[100]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : isSelected
                          ? Colors.orange[800]
                          : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysProgress(int warmupCount, int mainCount) {
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
              child: _buildProgressCircle(
                title: 'Warm up',
                completed: _warmupCompleted,
                total: warmupCount,
                remainingMin: warmupRemaining,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressCircle(
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

  Widget _buildProgressCircle({
    required String title,
    required int completed,
    required int total,
    required int remainingMin,
    required Color color,
  }) {
    final progress = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    '$completed/$total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$remainingMin min remaining',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onStart,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: onStart,
            child: const Text(
              'Start',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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

  Widget _buildAnalyticPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingPage() {
    final user = _currentUser!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange[100],
            child: Text(
              user.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildSettingItem('Age', '${user.age} years', Icons.cake),
          _buildSettingItem(
            'Weight',
            '${user.weight.toStringAsFixed(1)} kg',
            Icons.monitor_weight,
          ),
          _buildSettingItem(
            'Height',
            '${user.height.toStringAsFixed(0)} cm',
            Icons.height,
          ),
          _buildSettingItem(
            'Plan',
            user.selectedPlan.displayName,
            Icons.home_work,
          ),
          _buildSettingItem(
            'Level',
            user.selectedLevel.displayName,
            Icons.trending_up,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.analytics, 'Analytic'),
            _buildNavItem(2, Icons.settings, 'Setting'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================
// Workout List Screen (Frame 6 & 20)
// ===========================================
class WorkoutListScreen extends StatelessWidget {
  final String title;
  final List<Exercise> exercises;
  final Level userLevel;
  final Function(Exercise) onExerciseCompleted;

  const WorkoutListScreen({
    super.key,
    required this.title,
    required this.exercises,
    required this.userLevel,
    required this.onExerciseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 16),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 90,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: exercises.isEmpty
          ? const Center(child: Text('No exercises available'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return _buildExerciseCard(context, exercise);
              },
            ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    final sets = exercise.getSetsForLevel(userLevel);
    final reps = exercise.getRepsForLevel(userLevel);
    final duration = exercise.getDurationForLevel(userLevel);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(
              exercise: exercise,
              userLevel: userLevel,
              onDone: () => onExerciseCompleted(exercise),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${duration > 0 ? "${duration}s" : "7-10 min"}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Amount: $sets sets',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '1 set = $reps reps/times',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.check, color: Colors.orange, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================
// Exercise Detail Screen (Frame 19)
// ===========================================
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final Level userLevel;
  final VoidCallback onDone;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.userLevel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final sets = exercise.getSetsForLevel(userLevel);
    final reps = exercise.getRepsForLevel(userLevel);
    final duration = exercise.getDurationForLevel(userLevel);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 16),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 90,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                exercise.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.orange[300],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How to do:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...exercise.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Duration: ${duration > 0 ? "${duration}s" : "7-10 mins"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Amounts: $sets Sets',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '1 set = $reps reps/times',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            onDone();
            Navigator.pop(context);
          },
          child: const Text(
            'Done',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
