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
  late List<Exercise> _remainingExercises;

  @override
  void initState() {
    super.initState();
    _remainingExercises = List.from(widget.exercises);
  }

  void _markExerciseComplete(Exercise exercise) {
    setState(() {
      _remainingExercises.removeWhere((e) => e.id == exercise.id);
    });
    widget.onExerciseCompleted(exercise);
    
    // If all exercises are done, show completion message and go back
    if (_remainingExercises.isEmpty) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: _remainingExercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'All exercises completed!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _remainingExercises.length,
              itemBuilder: (context, index) {
                final exercise = _remainingExercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  userLevel: widget.userLevel,
                  onTap: () {
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
                  },
                );
              },
            ),
    );
  }
}
