import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/common/back_button.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final Level userLevel;
  final String userId;
  final VoidCallback onDone;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.userLevel,
    required this.userId,
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
        leading: const OrangeBackButton(),
        leadingWidth: 90,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
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

            // Exercise image placeholder
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

            // Instructions
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

            // Exercise details
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
          onPressed: () async {
            // Save the exercise session to database
            final session = ExerciseSession(
              userId: userId,
              exerciseId: exercise.id,
              date: DateTime.now(),
              setsCompleted: exercise.getSetsForLevel(userLevel),
              repsCompleted: exercise.getRepsForLevel(userLevel),
              durationSeconds: exercise.getDurationForLevel(userLevel),
            );

            await SessionRepository().saveSession(session);

            onDone();
            if (context.mounted) {
              Navigator.pop(context);
            }
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
