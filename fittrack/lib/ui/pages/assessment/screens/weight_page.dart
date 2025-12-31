import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';

/// Single page for Weight selection
/// Clean, focused, reusable, and testable
class WeightPage extends StatefulWidget {
  final double initialWeight;
  final Function(double) onWeightChanged;
  final VoidCallback onNext;

  const WeightPage({
    super.key,
    required this.initialWeight,
    required this.onWeightChanged,
    required this.onNext,
  });

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  late double _currentWeight;

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.initialWeight;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "What's your current\nweight right now?",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large weight display
          Text(
            '${_currentWeight.toStringAsFixed(1)} Kg',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 40),

          // Weight slider
          Slider(
            value: _currentWeight,
            min: 30,
            max: 150,
            divisions: 240,
            activeColor: Colors.orange[800],
            inactiveColor: Colors.grey[700],
            label: '${_currentWeight.toStringAsFixed(1)} Kg',
            onChanged: (value) {
              setState(() {
                _currentWeight = double.parse(value.toStringAsFixed(1));
              });
              widget.onWeightChanged(_currentWeight);
            },
          ),
          const SizedBox(height: 20),

          // Helper text
          Text(
            'Slide to select your weight',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
