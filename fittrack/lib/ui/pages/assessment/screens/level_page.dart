import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';
import '../../../../core/constants/enums.dart';

/// Single page for Level selection
/// Clean, focused, reusable, and testable
class LevelPage extends StatefulWidget {
  final Level initialLevel;
  final Function(Level) onLevelChanged;
  final VoidCallback onNext;

  const LevelPage({
    super.key,
    required this.initialLevel,
    required this.onLevelChanged,
    required this.onNext,
  });

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late Level _currentLevel;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "Select the level",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOptionButton(
            'Beginner',
            Icons.star_border,
            _currentLevel == Level.beginner,
            () {
              setState(() {
                _currentLevel = Level.beginner;
              });
              widget.onLevelChanged(_currentLevel);
            },
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            'Intermediate',
            Icons.star_half,
            _currentLevel == Level.intermediate,
            () {
              setState(() {
                _currentLevel = Level.intermediate;
              });
              widget.onLevelChanged(_currentLevel);
            },
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            'Advanced',
            Icons.star,
            _currentLevel == Level.advanced,
            () {
              setState(() {
                _currentLevel = Level.advanced;
              });
              widget.onLevelChanged(_currentLevel);
            },
          ),
        ],
      ),
    );
  }

  // Helper: Option button
  Widget _buildOptionButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
