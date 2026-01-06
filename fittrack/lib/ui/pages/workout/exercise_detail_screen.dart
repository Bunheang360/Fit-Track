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
  // ==========================================
  // STATE VARIABLES
  // ==========================================
  /// Flag to prevent multiple submissions when user taps Done button
  bool _isCompleting = false;

  // ==========================================
  // HANDLE DONE BUTTON
  // ==========================================
  /// When user taps Done, save session to database and go back.
  Future<void> _handleDone() async {
    // Step 1: Check if already completing (prevent double tap)
    if (_isCompleting) return;

    // Step 2: Show loading state
    setState(() {
      _isCompleting = true;
    });

    try {
      // Step 3: Create and save session
      await _saveExerciseSession();

      // Step 4: Notify parent and go back
      widget.onDone();
      _goBack();
    } catch (e) {
      // Step 5: If error, reset loading state
      _resetLoadingState();
    }
  }

  // ==========================================
  // SAVE EXERCISE SESSION TO DATABASE
  // ==========================================
  Future<void> _saveExerciseSession() async {
    final session = ExerciseSession(
      userId: widget.userId,
      exerciseId: widget.exercise.id,
      date: DateTime.now(),
      setsCompleted: widget.exercise.getSetsForLevel(widget.userLevel),
      repsCompleted: widget.exercise.getRepsForLevel(widget.userLevel),
      durationSeconds: widget.exercise.getDurationForLevel(widget.userLevel),
    );

    await SessionRepository().saveSession(session);
  }

  // ==========================================
  // GO BACK TO PREVIOUS SCREEN
  // ==========================================
  void _goBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ==========================================
  // RESET LOADING STATE (ON ERROR)
  // ==========================================
  void _resetLoadingState() {
    if (mounted) {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  // ==========================================
  // BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final sets = widget.exercise.getSetsForLevel(widget.userLevel);
    final reps = widget.exercise.getRepsForLevel(widget.userLevel);
    final duration = widget.exercise.getDurationForLevel(widget.userLevel);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildDoneButton(),
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
    );
  }

  // ==========================================
  // BUILD BODY
  // ==========================================
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseName(),
          const SizedBox(height: 24),
          _buildExerciseImage(),
          const SizedBox(height: 24),
          _buildInstructions(),
          const SizedBox(height: 24),
          _buildExerciseDetails(),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD EXERCISE NAME
  // ==========================================
  Widget _buildExerciseName() {
    return Center(
      child: Text(
        widget.exercise.name,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==========================================
  // BUILD EXERCISE IMAGE
  // ==========================================
  Widget _buildExerciseImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.fitness_center, size: 80, color: Colors.orange[300]),
      ),
    );
  }

  // ==========================================
  // BUILD INSTRUCTIONS LIST
  // ==========================================
  Widget _buildInstructions() {
    List<Widget> instructionWidgets = [];

    // Add header
    instructionWidgets.add(
      const Text(
        'How to do:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
    instructionWidgets.add(const SizedBox(height: 12));

    // Add each instruction step
    for (int i = 0; i < widget.exercise.instructions.length; i++) {
      instructionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  widget.exercise.instructions[i],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructionWidgets,
    );
  }

  // ==========================================
  // BUILD EXERCISE DETAILS (SETS, REPS, DURATION)
  // ==========================================
  Widget _buildExerciseDetails() {
    final sets = widget.exercise.getSetsForLevel(widget.userLevel);
    final reps = widget.exercise.getRepsForLevel(widget.userLevel);
    final duration = widget.exercise.getDurationForLevel(widget.userLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  // ==========================================
  // BUILD DONE BUTTON
  // ==========================================
  Widget _buildDoneButton() {
    return Padding(
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
        child: _isCompleting ? _buildLoadingIndicator() : _buildDoneText(),
      ),
    );
  }

  // ==========================================
  // BUILD LOADING INDICATOR
  // ==========================================
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }

  // ==========================================
  // BUILD DONE TEXT
  // ==========================================
  Widget _buildDoneText() {
    return const Text(
      'Done',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
