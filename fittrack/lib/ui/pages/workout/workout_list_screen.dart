import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/workout/exercise_card.dart';
import '../../widgets/common/back_button.dart';
import 'exercise_detail_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  final String title;
  final List<Exercise> exercises;
  final Level userLevel;
  final String userId;
  final Function(Exercise) onExerciseCompleted;
  final int? goalRemaining; // Exercises needed to reach goal
  final int? goalTotal; // Total goal for this section

  const WorkoutListScreen({
    super.key,
    required this.title,
    required this.exercises,
    required this.userLevel,
    required this.userId,
    required this.onExerciseCompleted,
    this.goalRemaining,
    this.goalTotal,
  });

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  // STATE VARIABLES
  late List<Exercise> _remainingExercises;
  int _completedInSession = 0; // Track how many completed this session

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _remainingExercises = List.from(widget.exercises);
  }

  // Calculate remaining exercises needed for goal
  int get _goalRemaining =>
      (widget.goalRemaining ?? _remainingExercises.length) -
      _completedInSession;

  // Check if goal is reached
  bool get _isGoalReached => _goalRemaining <= 0;

  /// MARK EXERCISE COMPLETE
  // When user finishes an exercise, remove it from the list.
  // If goal is reached, show message and go back.
  void _markExerciseComplete(Exercise exercise) {
    // 1: Remove from remaining list
    setState(() {
      _removeExerciseFromList(exercise);
      _completedInSession++;
    });

    // 2: Notify parent screen
    widget.onExerciseCompleted(exercise);

    // 3: Check if goal is reached
    if (_isGoalReached) {
      _showGoalReachedAndGoBack();
    } else if (_remainingExercises.isEmpty) {
      _showCompletionAndGoBack();
    }
  }

  // REMOVE EXERCISE FROM LIST VIEW
  void _removeExerciseFromList(Exercise exercise) {
    _remainingExercises.removeWhere((e) => e.id == exercise.id);
  }

  // SHOW GOAL REACHED MESSAGE AND GO BACK
  void _showGoalReachedAndGoBack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} goal reached! 🎉 Great job!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // SHOW COMPLETION MESSAGE AND GO BACK
  void _showCompletionAndGoBack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} completed! Great job!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // NAVIGATE TO EXERCISE DETAIL
  void _openExerciseDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exercise: exercise,
          userLevel: widget.userLevel,
          userId: widget.userId,
          onDone: () => _markExerciseComplete(exercise),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _remainingExercises.isEmpty
          ? _buildEmptyState()
          : _buildExerciseGrid(),
    );
  }

  // APP BAR
  AppBar _buildAppBar() {
    // Show goal progress if goals are set
    final hasGoal = widget.goalTotal != null;
    final goalText = hasGoal
        ? '$_goalRemaining/${widget.goalTotal} to go'
        : '${_remainingExercises.length} left';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const OrangeBackButton(),
      leadingWidth: 90,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isGoalReached
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _isGoalReached ? '✓ Goal reached!' : goalText,
                style: TextStyle(
                  color: _isGoalReached ? Colors.green : Colors.orange[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // EMPTY STATE (ALL DONE)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
          const SizedBox(height: 16),
          const Text(
            'All exercises completed!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // EXERCISE GRID
  Widget _buildExerciseGrid() {
    return Column(
      children: [
        // Goal progress header
        if (widget.goalTotal != null) _buildGoalProgressHeader(),
        // Exercise grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
              childAspectRatio: MediaQuery.of(context).size.width >= 600
                  ? 1.3
                  : 1.15,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _remainingExercises.length,
            itemBuilder: (context, index) {
              final exercise = _remainingExercises[index];
              return ExerciseCard(
                exercise: exercise,
                userLevel: widget.userLevel,
                onTap: () => _openExerciseDetail(exercise),
              );
            },
          ),
        ),
      ],
    );
  }

  // Goal progress header
  Widget _buildGoalProgressHeader() {
    final completed = _completedInSession;
    final total = widget.goalRemaining ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose $_goalRemaining more exercise${_goalRemaining == 1 ? "" : "s"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_remainingExercises.length} available',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isGoalReached ? Colors.green : Colors.orange,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
