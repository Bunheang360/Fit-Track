import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';
import '../../../../core/constants/enums.dart';

/// Single page for Schedule selection
/// Clean, focused, reusable, and testable
class SchedulePage extends StatefulWidget {
  final List<DayOfWeek> initialDays;
  final Function(List<DayOfWeek>) onDaysChanged;
  final VoidCallback onNext;

  const SchedulePage({
    super.key,
    required this.initialDays,
    required this.onDaysChanged,
    required this.onNext,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late List<DayOfWeek> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.initialDays);
  }

  void _handleDayToggle(DayOfWeek day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    widget.onDaysChanged(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "Select the schedule",
      subtitle: "Choose your workout days",
      onNext: widget.onNext,
      isLastPage: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: DayOfWeek.values.map((day) {
              final isSelected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () => _handleDayToggle(day),
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
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        day.displayName,
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
          ),
          const SizedBox(height: 30),
          if (_selectedDays.isNotEmpty)
            Text(
              '${_selectedDays.length} days selected',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
        ],
      ),
    );
  }
}
