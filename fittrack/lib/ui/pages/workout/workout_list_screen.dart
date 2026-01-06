import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
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

  const WorkoutListScreen({
    super.key,
    required this.title,
    required this.exercises,
    required this.userLevel,
    required this.userId,
    required this.onExerciseCompleted,
  });

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  // ==========================================
  // STATE VARIABLES
  // ==========================================
  late List<Exercise> _remainingExercises;

  // ==========================================
  // INITIALIZATION
  // ==========================================
  @override
  void initState() {
    super.initState();
    _remainingExercises = List.from(widget.exercises);
  }

  // ==========================================
  // MARK EXERCISE COMPLETE
  // ==========================================
  /// When user finishes an exercise, remove it from the list.
  /// If all exercises are done, show message and go back.
  void _markExerciseComplete(Exercise exercise) {
    // Step 1: Remove from remaining list
    setState(() {
      _removeExerciseFromList(exercise);
    });

    // Step 2: Notify parent screen
    widget.onExerciseCompleted(exercise);

    // Step 3: Check if all done
    if (_remainingExercises.isEmpty) {
      _showCompletionAndGoBack();
    }
  }

  // ==========================================
  // REMOVE EXERCISE FROM LIST
  // ==========================================
  void _removeExerciseFromList(Exercise exercise) {
    _remainingExercises.removeWhere((e) => e.id == exercise.id);
  }

  // ==========================================
  // SHOW COMPLETION MESSAGE AND GO BACK
  // ==========================================
  void _showCompletionAndGoBack() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} completed! Great job!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Wait a bit then go back
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  // ==========================================
  // NAVIGATE TO EXERCISE DETAIL
  // ==========================================
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

  // ==========================================
  // BUILD UI
  // ==========================================
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

  // ==========================================
  // BUILD APP BAR
  // ==========================================
  AppBar _buildAppBar() {
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
            child: Text(
              '${_remainingExercises.length} left',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BUILD EMPTY STATE (ALL DONE)
  // ==========================================
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

  // ==========================================
  // BUILD EXERCISE GRID
  // ==========================================
  Widget _buildExerciseGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
        childAspectRatio: MediaQuery.of(context).size.width >= 600 ? 1.3 : 1.15,
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
    );
  }
}
