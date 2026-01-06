import 'package:flutter/material.dart';
import 'question_screen.dart';

// ============================================================================
// ASSESSMENT INTRO SCREEN (Frame 4)
// ============================================================================
/// This screen appears after signup, before the assessment questions.
/// It shows a motivational message and lets user start the assessment.
class AssessmentIntroScreen extends StatelessWidget {
  // ==========================================
  // CONSTRUCTOR PARAMETERS
  // ==========================================
  /// User credentials passed from signup screen
  final String username;
  final String email;
  final String password;

  const AssessmentIntroScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  // ==========================================
  // BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundImage(),
          _buildDarkOverlay(),
          _buildContent(context),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD BACKGROUND IMAGE
  // ==========================================
  Widget _buildBackgroundImage() {
    return Image.asset(
      'assets/images/gym_pic.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback gradient if image not found
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[900]!, Colors.black],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // BUILD DARK OVERLAY
  // ==========================================
  Widget _buildDarkOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BUILD CONTENT
  // ==========================================
  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildSubtitle(),
            const Spacer(flex: 1),
            _buildAssessmentButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BUILD TITLE
  // ==========================================
  Widget _buildTitle() {
    return const Text(
      "LET'S GET RIPPED\nAND JACKED",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.1,
        letterSpacing: 1,
      ),
    );
  }

  // ==========================================
  // BUILD SUBTITLE
  // ==========================================
  Widget _buildSubtitle() {
    return Text(
      'Personalized workouts and progress\ntracking to help you reach your goals.',
      style: TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.5),
    );
  }

  // ==========================================
  // BUILD ASSESSMENT BUTTON
  // ==========================================
  Widget _buildAssessmentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _goToQuestions(context),
        child: const Text(
          'Assessment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ==========================================
  // NAVIGATE TO QUESTIONS
  // ==========================================
  void _goToQuestions(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentQuestionsScreen(
          username: username,
          email: email,
          password: password,
        ),
      ),
    );
  }
}
