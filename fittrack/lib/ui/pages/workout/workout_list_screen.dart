import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/workout/exercise_card.dart';
import '../../widgets/common/back_button.dart';
import 'exercise_detail_screen.dart';

class WorkoutListScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const OrangeBackButton(),
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
                return ExerciseCard(
                  exercise: exercise,
                  userLevel: userLevel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(
                          exercise: exercise,
                          userLevel: userLevel,
                          userId: userId,
                          onDone: () => onExerciseCompleted(exercise),
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
