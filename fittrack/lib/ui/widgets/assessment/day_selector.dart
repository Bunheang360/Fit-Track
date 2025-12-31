import 'package:flutter/material.dart';

// ====================
// 5. DAY SELECTOR (for Schedule page)
// ====================
class DaySelector extends StatelessWidget {
  final String dayName;
  final bool isSelected;
  final VoidCallback onTap;

  const DaySelector({
    super.key,
    required this.dayName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              dayName,
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
  }
}