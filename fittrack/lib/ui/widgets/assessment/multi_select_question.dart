import 'package:flutter/material.dart';

/// Configuration for multi-select options
/// Uses String for value to keep it simple
class MultiSelectOption {
  final String value;
  final String label;

  const MultiSelectOption({required this.value, required this.label});
}

/// Display style for multi-select questions
enum MultiSelectStyle {
  chips, // For categories (ChoiceChips)
  grid, // For schedule (grid of boxes)
}

/// Reusable multi-select question widget
/// Used for Categories (chips) and Schedule (grid)
class MultiSelectQuestion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> initialValues;
  final List<MultiSelectOption> options;
  final Function(List<String>) onValuesChanged;
  final VoidCallback onNext;
  final bool isLastPage;
  final MultiSelectStyle style;
  final int minSelection; // Minimum required selections

  const MultiSelectQuestion({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialValues,
    required this.options,
    required this.onValuesChanged,
    required this.onNext,
    this.isLastPage = false,
    this.style = MultiSelectStyle.chips,
    this.minSelection = 0,
  });

  @override
  State<MultiSelectQuestion> createState() => _MultiSelectQuestionState();
}

class _MultiSelectQuestionState extends State<MultiSelectQuestion> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.initialValues);
  }

  void _toggleSelection(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
    widget.onValuesChanged(_selectedValues);
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

          // Options content
          Expanded(
            child: SingleChildScrollView(
              child: widget.style == MultiSelectStyle.chips
                  ? _buildChipsLayout()
                  : _buildGridLayout(),
            ),
          ),

          // Selection count
          if (_selectedValues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: Text(
                  '${_selectedValues.length} selected',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ),
            ),

          const SizedBox(height: 10),

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

  /// Chips layout for categories
  Widget _buildChipsLayout() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.value);
        return ChoiceChip(
          label: Text(
            option.label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.orange[800],
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.orange : Colors.grey[700]!,
              width: 1.5,
            ),
          ),
          onSelected: (_) => _toggleSelection(option.value),
        );
      }).toList(),
    );
  }

  /// Grid layout for schedule days
  Widget _buildGridLayout() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.value);
        return GestureDetector(
          onTap: () => _toggleSelection(option.value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange[800] : Colors.grey[850],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                Text(
                  option.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
