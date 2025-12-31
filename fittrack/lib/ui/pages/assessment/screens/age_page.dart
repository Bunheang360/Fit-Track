import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';

/// Single page for Age selection
/// Clean, focused, reusable, and testable
class AgePage extends StatefulWidget {
  final int initialAge;
  final Function(int) onAgeChanged;
  final VoidCallback onNext;

  const AgePage({
    super.key,
    required this.initialAge,
    required this.onAgeChanged,
    required this.onNext,
  });

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  late int _currentAge;

  @override
  void initState() {
    super.initState();
    _currentAge = widget.initialAge;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "What's your Age?",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large age display
          Text(
            '$_currentAge',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 40),

          // Age slider
          Slider(
            value: _currentAge.toDouble(),
            min: 13,
            max: 80,
            divisions: 67,
            activeColor: Colors.orange[800],
            inactiveColor: Colors.grey[700],
            label: '$_currentAge years',
            onChanged: (value) {
              setState(() {
                _currentAge = value.toInt();
              });
              widget.onAgeChanged(_currentAge);
            },
          ),
          const SizedBox(height: 20),

          // Helper text
          Text(
            'Slide to select your age',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
