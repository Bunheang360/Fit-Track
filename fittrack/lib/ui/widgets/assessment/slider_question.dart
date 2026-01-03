import 'package:flutter/material.dart';

/// Reusable slider question widget for numeric values (age, weight, height)
/// Uses double for all numeric values to keep it simple
class SliderQuestion extends StatefulWidget {
  final String title;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final int? divisions;
  final String unit;
  final bool showAsInteger; // If true, display as whole number (for age)
  final Function(double) onValueChanged;
  final VoidCallback onNext;
  final bool isLastPage;

  const SliderQuestion({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.divisions,
    this.unit = '',
    this.showAsInteger = false,
    required this.onValueChanged,
    required this.onNext,
    this.isLastPage = false,
  });

  @override
  State<SliderQuestion> createState() => _SliderQuestionState();
}

class _SliderQuestionState extends State<SliderQuestion> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  String _getDisplayValue() {
    // Format based on whether we want integer or decimal display
    if (widget.showAsInteger) {
      return '${_currentValue.toInt()}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}';
    } else {
      return '${_currentValue.toStringAsFixed(1)}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}';
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentValue = value;
    });
    widget.onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 40),

          // Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large value display
                Text(
                  _getDisplayValue(),
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 40),

                // Slider
                Slider(
                  value: _currentValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: widget.divisions,
                  activeColor: Colors.orange[800],
                  inactiveColor: Colors.grey[700],
                  label: _getDisplayValue(),
                  onChanged: _onSliderChanged,
                ),
                const SizedBox(height: 20),

                // Helper text
                Text(
                  'Slide to select',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
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
              onPressed: widget.onNext,
              child: Text(
                widget.isLastPage ? 'Complete' : 'Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
