import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/models/workout.dart';
import '../../../data/services/workout_service.dart';
import '../../../data/repositories/setting_repositories.dart';
import '../../../core/constants/enums.dart';
import '../../../core/extensions.dart';
import '../../../core/constants/ui_constants.dart';
import '../../widgets/workout/workout_cards.dart';
import '../authentication/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WorkoutService _workoutService;
  late final SettingsRepository _settingsRepository;
  late List<Workout> _warmupWorkouts = [];
  late List<Workout> _mainWorkouts = [];
  int _currentTabIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _workoutService = WorkoutService();
    _settingsRepository = SettingsRepository();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    try {
      final allWorkouts =
          _workoutService.getRecommendedWorkouts(widget.user);
      final categorized =
          _workoutService.categorizeWorkouts(allWorkouts);

      setState(() {
        _warmupWorkouts = categorized.warmups;
        _mainWorkouts = categorized.mains;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _settingsRepository.setLoggedOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeTab(),
            _buildAnalyticsTab(),
            _buildSettingsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // ---------------- HOME TAB ----------------

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: HomeScreenConstants.standardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklySchedule(),
            HomeScreenConstants.verticalSpacing32,
            _buildProgressSection(),
            HomeScreenConstants.verticalSpacing32,
            _buildActionButtons(),
            HomeScreenConstants.verticalSpacing32,
            if (_warmupWorkouts.isNotEmpty)
              _buildExerciseSection(
                'Warm Up',
                _warmupWorkouts,
                isWarmup: true,
              ),
            if (_mainWorkouts.isNotEmpty)
              _buildExerciseSection(
                'Main Workout',
                _mainWorkouts,
                isWarmup: false,
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello ${widget.user.name}!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${widget.user.selectedPlan.displayName} Plan',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    const days = ['1', '2', '3', '4', '5', '6', '7'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Schedule',
          style: TextStyle(color: Colors.grey[600]),
        ),
        HomeScreenConstants.verticalSpacing12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            days.length,
            (index) => _buildDaySelector(days[index], isSelected: index == 0),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(String day, {required bool isSelected}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          isSelected ? Colors.orange[800] : Colors.grey[200],
      child: Text(
        day,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            title: 'Progress',
            value: '1/5',
            subtitle: '0 min remaining',
          ),
        ),
        HomeScreenConstants.horizontalSpacing12,
        Expanded(
          child: _buildProgressCard(
            title: 'Plan',
            value: '1/15',
            subtitle: '60 min remaining',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          HomeScreenConstants.verticalSpacing12,
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.fitness_center,
            title: 'Warm Up',
            subtitle: 'Stretching & cardio',
            onTap: () => _showWorkoutList('Warm Up', _warmupWorkouts),
          ),
        ),
        HomeScreenConstants.horizontalSpacing12,
        Expanded(
          child: _buildActionButton(
            icon: Icons.bolt,
            title: 'Main Workout',
            subtitle: 'Full body',
            onTap: () => _showWorkoutList('Main Workout', _mainWorkouts),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            HomeScreenConstants.verticalSpacing12,
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text(subtitle,
                style:
                    TextStyle(color: Colors.white.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(
    String title,
    List<Workout> workouts, {
    required bool isWarmup,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _showWorkoutList(title, workouts),
              child: Text('See All',
                  style: TextStyle(color: Colors.orange[800])),
            ),
          ],
        ),
        HomeScreenConstants.verticalSpacing12,
        isWarmup
            ? _buildHorizontalScrollList(workouts)
            : _buildGridList(workouts),
      ],
    );
  }

  Widget _buildHorizontalScrollList(List<Workout> workouts) {
    return SizedBox(
      height: HomeScreenConstants.horizontalCardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: workouts.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: HorizontalWorkoutCard(
            workout: workouts[index],
            onTap: () => _showWorkoutDetail(workouts[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildGridList(List<Workout> workouts) {
    return GridView.count(
      crossAxisCount: HomeScreenConstants.gridCrossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: HomeScreenConstants.gridSpacing,
      mainAxisSpacing: HomeScreenConstants.gridSpacing,
      children: workouts
          .map(
            (w) => WorkoutCard(
              workout: w,
              onTap: () => _showWorkoutDetail(w),
            ),
          )
          .toList(),
    );
  }

  void _showWorkoutDetail(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(
          workout: workout,
          userLevel: widget.user.selectedLevel,
        ),
      ),
    );
  }

  void _showWorkoutList(String title, List<Workout> workouts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _buildWorkoutListModal(title, workouts),
    );
  }

  Widget _buildWorkoutListModal(String title, List<Workout> workouts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (_, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout.title),
                subtitle: Text(workout.basicMetrics),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.pop(context);
                  _showWorkoutDetail(workout);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- OTHER TABS ----------------

  Widget _buildAnalyticsTab() {
    return const Scaffold(
      body: Center(child: Text('Analytics - Coming Soon')),
    );
  }

  Widget _buildSettingsTab() {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('User Profile'),
            subtitle: Text(widget.user.name),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: _onTabChanged,
      selectedItemColor: Colors.orange[800],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.analytics), label: 'Analytics'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// ---------------- DETAIL SCREEN ----------------

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  final Level userLevel;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    final sets = workout.getSetsForLevel(userLevel);
    final reps = workout.getRepsForLevel(userLevel);

    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(workout.description),
            const SizedBox(height: 20),
            Text('$sets sets • $reps repetitions'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
