import 'package:flutter/material.dart';

class ProgressCircle extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final int remainingMin;
  final Color color;

  const ProgressCircle({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.remainingMin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = (screenWidth * 0.18).clamp(60.0, 90.0);
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth < 360 ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$remainingMin min remaining',
            style: TextStyle(
              fontSize: screenWidth < 360 ? 10 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
