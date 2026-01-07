import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';

class WeeklySchedule extends StatelessWidget {
  final List<DayOfWeek> selectedDays;

  const WeeklySchedule({super.key, required this.selectedDays});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final dayHeight = isSmall ? 40.0 : 50.0;
    final dayFontSize = isSmall ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final dayEnum = DayOfWeek.values[index];
              final isSelected = selectedDays.contains(dayEnum);
              final isToday = today == dayNumber;
              final dayNames = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ];

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isSmall ? 1 : 3),
                  height: dayHeight,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.orange
                        : isSelected
                        ? Colors.orange[100]
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isSmall
                          ? dayNames[index].substring(0, 1)
                          : dayNames[index],
                      style: TextStyle(
                        fontSize: dayFontSize,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? Colors.white
                            : isSelected
                            ? Colors.orange[800]
                            : Colors.grey[500],
                      ),
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
