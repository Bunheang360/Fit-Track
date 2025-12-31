import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';

/// Single page for Height selection
/// Clean, focused, reusable, and testable
class HeightPage extends StatefulWidget {
  final double initialHeight;
  final Function(double) onHeightChanged;
  final VoidCallback onNext;

  const HeightPage({
    super.key,
    required this.initialHeight,
    required this.onHeightChanged,
    required this.onNext,
  });

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  late double _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "What is your height?",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large height display
          Text(
            '${_currentHeight.toStringAsFixed(0)} cm',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 40),

          // Height slider
          Slider(
            value: _currentHeight,
            min: 120,
            max: 220,
            divisions: 100,
            activeColor: Colors.orange[800],
            inactiveColor: Colors.grey[700],
            label: '${_currentHeight.toStringAsFixed(0)} cm',
            onChanged: (value) {
              setState(() {
                _currentHeight = value;
              });
              widget.onHeightChanged(_currentHeight);
            },
          ),
          const SizedBox(height: 20),

          // Helper text
          Text(
            'Slide to select your height',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
