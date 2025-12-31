import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';
import '../../../../core/constants/enums.dart';

/// Single page for Gender selection
/// Clean, focused, reusable, and testable
class GenderPage extends StatefulWidget {
  final Gender initialGender;
  final Function(Gender) onGenderChanged;
  final VoidCallback onNext;

  const GenderPage({
    super.key,
    required this.initialGender,
    required this.onGenderChanged,
    required this.onNext,
  });

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  late Gender _currentGender;

  @override
  void initState() {
    super.initState();
    _currentGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "What is your gender?",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOptionButton(
            'Male',
            Icons.male,
            _currentGender == Gender.male,
            () {
              setState(() {
                _currentGender = Gender.male;
              });
              widget.onGenderChanged(_currentGender);
            },
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            'Female',
            Icons.female,
            _currentGender == Gender.female,
            () {
              setState(() {
                _currentGender = Gender.female;
              });
              widget.onGenderChanged(_currentGender);
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
