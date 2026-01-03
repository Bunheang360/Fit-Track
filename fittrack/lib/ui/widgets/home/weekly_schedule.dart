import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';

class WeeklySchedule extends StatelessWidget {
  final List<DayOfWeek> selectedDays;

  const WeeklySchedule({super.key, required this.selectedDays});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final dayEnum = DayOfWeek.values[index];
              final isSelected = selectedDays.contains(dayEnum);
              final isToday = today == dayNumber;

              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.orange
                      : isSelected
                      ? Colors.orange[100]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : isSelected
                          ? Colors.orange[800]
                          : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
