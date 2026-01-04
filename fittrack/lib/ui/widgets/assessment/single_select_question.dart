import 'package:flutter/material.dart';

/// Configuration for a single select option
/// Uses String for value to keep it simple
class SelectOption {
  final String value;
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

/// Reusable single-select question widget for String-based choices
/// Used for Gender, Level, Plan selections
class SingleSelectQuestion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String initialValue;
  final List<SelectOption> options;
  final Function(String) onValueChanged;
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
  State<SingleSelectQuestion> createState() => _SingleSelectQuestionState();
}

class _SingleSelectQuestionState extends State<SingleSelectQuestion> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _onOptionSelected(String value) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              height: 1.2,
            ),
          ),

          if (widget.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],

          const SizedBox(height: 40),

          // Options
          Expanded(
            child: Center(
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
  Widget _buildSimpleOption(SelectOption option, bool isSelected) {
    return GestureDetector(
      onTap: () => _onOptionSelected(option.value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : Colors.orange[800],
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card option with description (Plan)
  Widget _buildCardOption(SelectOption option, bool isSelected) {
    return GestureDetector(
      onTap: () => _onOptionSelected(option.value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              option.icon,
              color: isSelected ? Colors.white : Colors.orange[800],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            if (option.description != null) ...[
              const SizedBox(height: 8),
              Text(
                option.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
