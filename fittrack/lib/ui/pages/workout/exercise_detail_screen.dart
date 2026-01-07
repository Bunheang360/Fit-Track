import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../../../services/workout_service.dart';
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
  // Service for workout operations
  final _workoutService = WorkoutService();

  /// STATE VARIABLES
  // Flag to prevent multiple submissions when user taps Done button
  bool _isCompleting = false;

  /// HANDLE DONE BUTTON
  // When user taps Done, save session to database and go back.
  Future<void> _handleDone() async {
    // 1: Check if already completing (prevent double tap)
    if (_isCompleting) return;

    // 2: Show loading state
    setState(() {
      _isCompleting = true;
    });

    try {
      // 3: Create and save session
      await _saveExerciseSession();

      // 4: Notify parent and go back
      widget.onDone();
      _goBack();
    } catch (e) {
      // 5: If error, reset loading state
      _resetLoadingState();
    }
  }

  // SAVE EXERCISE SESSION VIA SERVICE
  Future<void> _saveExerciseSession() async {
    await _workoutService.completeExercise(
      userId: widget.userId,
      exercise: widget.exercise,
      userLevel: widget.userLevel,
    );
  }

  // GO BACK TO PREVIOUS SCREEN
  void _goBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // RESET LOADING STATE (ON ERROR)
  void _resetLoadingState() {
    if (mounted) {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildDoneButton(),
    );
  }

  // APP BAR
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const OrangeBackButton(),
      leadingWidth: 90,
    );
  }

  // BODY
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

  // EXERCISE NAME
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

  // EXERCISE IMAGE
  Widget _buildExerciseImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;

    // Responsive height based on screen size
    final imageHeight = isLandscape
        ? screenHeight * 0.35
        : isSmall
        ? screenHeight * 0.2
        : screenHeight * 0.25;

    return Container(
      height: imageHeight.clamp(150.0, 300.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        child: Image.asset(
          widget.exercise.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.fitness_center,
                size: isSmall ? 60 : 80,
                color: Colors.orange[300],
              ),
            );
          },
        ),
      ),
    );
  }

  // INSTRUCTIONS LIST
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

  // EXERCISE DETAILS (SETS, REPS, DURATION)
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

  // DONE BUTTON
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

  Widget _buildDoneText() {
    return const Text(
      'Done',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  // LOADING INDICATOR
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }
}
