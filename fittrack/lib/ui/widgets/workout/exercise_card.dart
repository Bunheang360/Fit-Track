import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../core/constants/enums.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Level userLevel;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.userLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sets = exercise.getSetsForLevel(userLevel);
    final reps = exercise.getRepsForLevel(userLevel);
    final duration = exercise.getDurationForLevel(userLevel);

    return GestureDetector(
      onTap: onTap,
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
