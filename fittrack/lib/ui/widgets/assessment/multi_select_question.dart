import 'package:flutter/material.dart';

// Configuration for multi-select options
class MultiSelectOption {
  final String value;
  final String label;
  final IconData? icon;

  const MultiSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

// Display style for multi-select questions
enum MultiSelectStyle { chips, grid }

// Reusable multi-select question widget
// Used for Categories (chips) and Schedule (grid)
class MultiSelectQuestion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> initialValues;
  final List<MultiSelectOption> options;
  final Function(List<String>) onValuesChanged;
  final VoidCallback onNext;
  final bool isLastPage;
  final MultiSelectStyle style;
  final int minSelection;

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

  // Get icon for category based on value name
  IconData _getCategoryIcon(String value) {
    switch (value) {
      case 'strength':
        return Icons.fitness_center;
      case 'endurance':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'loseFat':
        return Icons.local_fire_department;
      case 'getFit':
        return Icons.sports_gymnastics;
      case 'getTaller':
        return Icons.height;
      case 'cardio':
        return Icons.favorite;
      case 'mobility':
        return Icons.accessibility_new;
      case 'balance':
        return Icons.balance;
      case 'recovery':
        return Icons.spa;
      default:
        return Icons.star;
    }
  }

  // Get icon for day of week
  IconData _getDayIcon(String value) {
    switch (value) {
      case 'monday':
        return Icons.looks_one;
      case 'tuesday':
        return Icons.looks_two;
      case 'wednesday':
        return Icons.looks_3;
      case 'thursday':
        return Icons.looks_4;
      case 'friday':
        return Icons.looks_5;
      case 'saturday':
        return Icons.looks_6;
      case 'sunday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final padding = isSmall ? 20.0 : 30.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: isSmall ? 10 : 20),
          // Title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              height: 1.2,
            ),
          ),

          if (widget.subtitle != null) ...[
            SizedBox(height: isSmall ? 6 : 10),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],

          SizedBox(height: isSmall ? 30 : 40),

          // Options content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: widget.style == MultiSelectStyle.chips
                    ? _buildChipsLayout()
                    : _buildGridLayout(),
              ),
            ),
          ),

          // Selection count
          if (_selectedValues.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: isSmall ? 6 : 10),
              child: Center(
                child: Text(
                  '${_selectedValues.length} selected',
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

          SizedBox(height: isSmall ? 6 : 10),

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

  // Chips layout for categories - now with icons
  Widget _buildChipsLayout() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.value);
        final icon = option.icon ?? _getCategoryIcon(option.value);

        return GestureDetector(
          onTap: () => _toggleSelection(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange[800] : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.orange[800],
                ),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Grid layout for schedule days - improved with icons
  Widget _buildGridLayout() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: widget.options.map((option) {
        final isSelected = _selectedValues.contains(option.value);
        final icon = option.icon ?? _getDayIcon(option.value);

        return GestureDetector(
          onTap: () => _toggleSelection(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.orange[800]! : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon changes based on selection
                Icon(
                  isSelected ? Icons.check_circle : icon,
                  color: isSelected ? Colors.white : Colors.orange[800],
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 13,
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
