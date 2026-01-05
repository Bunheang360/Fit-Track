import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/common/back_button.dart';

class ExerciseDetailScreen extends StatefulWidget {
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
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  // Flag to prevent multiple submissions
  bool _isCompleting = false;

  // Method to handle done button press
  Future<void> _handleDone() async {
    // If already completing, ignore the press
    if (_isCompleting) return;

    // Set flag to prevent multiple presses
    setState(() {
      _isCompleting = true;
    });

    try {
      // Save the exercise session to database
      final session = ExerciseSession(
        userId: widget.userId,
        exerciseId: widget.exercise.id,
        date: DateTime.now(),
        setsCompleted: widget.exercise.getSetsForLevel(widget.userLevel),
        repsCompleted: widget.exercise.getRepsForLevel(widget.userLevel),
        durationSeconds: widget.exercise.getDurationForLevel(widget.userLevel),
      );

      await SessionRepository().saveSession(session);

      // Call the callback to notify parent
      widget.onDone();

      // Go back to previous screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // If error, allow user to try again
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.exercise.getSetsForLevel(widget.userLevel);
    final reps = widget.exercise.getRepsForLevel(widget.userLevel);
    final duration = widget.exercise.getDurationForLevel(widget.userLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const OrangeBackButton(),
        leadingWidth: 90,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmall ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
            Center(
              child: Text(
                widget.exercise.name,
                style: TextStyle(
                  fontSize: isSmall ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isSmall ? 16 : 24),

            // Exercise image placeholder
            Container(
              height: screenWidth * 0.5,
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
            ...widget.exercise.instructions.asMap().entries.map((entry) {
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
            backgroundColor: _isCompleting ? Colors.grey : Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isCompleting ? null : _handleDone,
          child: _isCompleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
