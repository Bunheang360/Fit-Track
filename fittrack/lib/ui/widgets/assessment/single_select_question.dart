import 'package:flutter/material.dart';

/// Configuration for a single select option
class SelectOption<T> {
  final T value;
  final String label;
  final IconData icon;
  final String? description;

  const SelectOption({
    required this.value,
    required this.label,
    required this.icon,
    this.description,
  });
}

/// Reusable single-select question widget for enum-based choices
/// Used for Gender, Level, Plan selections
class SingleSelectQuestion<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final T initialValue;
  final List<SelectOption<T>> options;
  final Function(T) onValueChanged;
  final VoidCallback onNext;
  final bool isLastPage;
  final bool showDescription; // For card-style options like Plan

  const SingleSelectQuestion({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialValue,
    required this.options,
    required this.onValueChanged,
    required this.onNext,
    this.isLastPage = false,
    this.showDescription = false,
  });

  @override
  State<SingleSelectQuestion<T>> createState() =>
      _SingleSelectQuestionState<T>();
}

class _SingleSelectQuestionState<T> extends State<SingleSelectQuestion<T>> {
  late T _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _onOptionSelected(T value) {
    setState(() {
      _selectedValue = value;
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

          if (widget.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],

          const SizedBox(height: 40),

          // Options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.options.map((option) {
                  final isSelected = _selectedValue == option.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: widget.showDescription
                        ? _buildCardOption(option, isSelected)
                        : _buildSimpleOption(option, isSelected),
                  );
                }).toList(),
              ),
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

  /// Simple option button (Gender, Level)
  Widget _buildSimpleOption(SelectOption<T> option, bool isSelected) {
    return GestureDetector(
      onTap: () => _onOptionSelected(option.value),
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
              child: Icon(option.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              option.label,
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

  /// Card option with description (Plan)
  Widget _buildCardOption(SelectOption<T> option, bool isSelected) {
    return GestureDetector(
      onTap: () => _onOptionSelected(option.value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(option.icon, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (option.description != null) ...[
              const SizedBox(height: 8),
              Text(
                option.description!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
