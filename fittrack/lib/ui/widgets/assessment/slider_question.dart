import 'package:flutter/material.dart';

/// Reusable slider question widget for numeric values (age, weight, height)
/// Eliminates redundancy by using configuration instead of separate files
class SliderQuestion<T extends num> extends StatefulWidget {
  final String title;
  final T initialValue;
  final T minValue;
  final T maxValue;
  final int? divisions;
  final String unit;
  final String Function(T)? formatValue;
  final Function(T) onValueChanged;
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
    this.formatValue,
    required this.onValueChanged,
    required this.onNext,
    this.isLastPage = false,
  });

  @override
  State<SliderQuestion<T>> createState() => _SliderQuestionState<T>();
}

class _SliderQuestionState<T extends num> extends State<SliderQuestion<T>> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.toDouble();
  }

  String _getDisplayValue() {
    if (widget.formatValue != null) {
      if (T == int) {
        return widget.formatValue!(_currentValue.toInt() as T);
      } else {
        return widget.formatValue!(_currentValue as T);
      }
    }

    // Default formatting based on type
    if (T == int) {
      return '${_currentValue.toInt()}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}';
    } else {
      return '${_currentValue.toStringAsFixed(1)}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}';
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentValue = value;
    });

    // Convert back to original type
    if (T == int) {
      widget.onValueChanged(value.toInt() as T);
    } else {
      widget.onValueChanged(double.parse(value.toStringAsFixed(1)) as T);
    }
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
                  min: widget.minValue.toDouble(),
                  max: widget.maxValue.toDouble(),
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
