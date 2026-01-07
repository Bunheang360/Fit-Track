import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../../../core/constants/enums.dart';
import '../../utils/responsive_utils.dart';

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
    // Get adjusted values based on user's fitness level
    final sets = exercise.getSetsForLevel(userLevel);
    final reps = exercise.getRepsForLevel(userLevel);
    final duration = exercise.getDurationForLevel(userLevel);
    final isSmall = context.isSmallScreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name in orange
            Text(
              exercise.name,
              style: TextStyle(
                fontSize: isSmall ? 11 : 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmall ? 4 : 6),

            // Duration
            Text(
              'Duration: ${duration > 0 ? "${duration}s" : "7-10 min"}',
              style: TextStyle(
                fontSize: isSmall ? 9 : 10,
                color: Colors.grey[600],
              ),
            ),
            // Amount (sets)
            Text(
              'Amount: $sets sets',
              style: TextStyle(
                fontSize: isSmall ? 9 : 10,
                color: Colors.grey[600],
              ),
            ),
            // Reps per set
            Text(
              '1 set = $reps reps/times',
              style: TextStyle(
                fontSize: isSmall ? 9 : 10,
                color: Colors.grey[600],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
