import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';
import '../../../../core/constants/enums.dart';

/// Single page for Categories selection
/// Clean, focused, reusable, and testable
class CategoriesPage extends StatefulWidget {
  final List<Categories> initialCategories;
  final Function(List<Categories>) onCategoriesChanged;
  final VoidCallback onNext;

  const CategoriesPage({
    super.key,
    required this.initialCategories,
    required this.onCategoriesChanged,
    required this.onNext,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late List<Categories> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialCategories);
  }

  void _handleCategoryToggle(Categories category, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
    widget.onCategoriesChanged(_selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "Categories",
      subtitle: "Select your fitness goals",
      onNext: widget.onNext,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: Categories.values.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return ChoiceChip(
              label: Text(
                cat.displayName,
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
              onSelected: (selected) => _handleCategoryToggle(cat, selected),
            );
          }).toList(),
        ),
      ),
    );
  }
}
