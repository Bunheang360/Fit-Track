import 'package:flutter/material.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../core/constants/enums.dart';

/// Shows workout statistics with Days/Weeks/Months filter
class AnalyticsScreen extends StatefulWidget {
  final String userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SessionRepository _sessionRepository = SessionRepository();

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.days;
  List<ExerciseSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final sessions = await _sessionRepository.getSessionsForUser(
        widget.userId,
      );
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Get workout data based on selected period
  Map<String, int> _getWorkoutData() {
    final now = DateTime.now();
    Map<String, int> data = {};

    switch (_selectedPeriod) {
      case AnalyticsPeriod.days:
        // Get data for each day of the current week (Mon-Sun)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          final dayStart = DateTime(day.year, day.month, day.day);
          final dayEnd = dayStart.add(const Duration(days: 1));

          final count = _sessions
              .where(
                (s) =>
                    s.date.isAfter(
                      dayStart.subtract(const Duration(seconds: 1)),
                    ) &&
                    s.date.isBefore(dayEnd),
              )
              .length;

          data[dayNames[i]] = count;
        }
        break;

      case AnalyticsPeriod.weeks:
        // Get data for the last 4 weeks
        for (int i = 3; i >= 0; i--) {
          final weekStart = now.subtract(
            Duration(days: now.weekday - 1 + (i * 7)),
          );
          final weekEnd = weekStart.add(const Duration(days: 7));

          final count = _sessions
              .where(
                (s) =>
                    s.date.isAfter(
                      weekStart.subtract(const Duration(seconds: 1)),
                    ) &&
                    s.date.isBefore(weekEnd),
              )
              .length;

          data['Week ${4 - i}'] = count;
        }
        break;

      case AnalyticsPeriod.months:
        // Get data for the last 6 months
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        for (int i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final nextMonth = DateTime(now.year, now.month - i + 1, 1);

          final count = _sessions
              .where(
                (s) =>
                    s.date.isAfter(
                      month.subtract(const Duration(seconds: 1)),
                    ) &&
                    s.date.isBefore(nextMonth),
              )
              .length;

          data[monthNames[month.month - 1]] = count;
        }
        break;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          const Text(
            'Analytic',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),

          // Period Selector (Days/Weeks/Months)
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Chart
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Days', AnalyticsPeriod.days),
          _buildPeriodButton('Weeks', AnalyticsPeriod.weeks),
          _buildPeriodButton('Months', AnalyticsPeriod.months),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, AnalyticsPeriod period) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final data = _getWorkoutData();
    final maxValue = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);
    final chartMax = maxValue == 0 ? 5 : (maxValue * 1.2).ceil();

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
            'Exercise',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                _buildYAxisLabels(chartMax),
                const SizedBox(width: 8),

                // Chart content
                Expanded(child: _buildChartContent(data, chartMax)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // X-axis labels
          _buildXAxisLabels(data.keys.toList()),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels(int maxValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$maxValue', style: _axisLabelStyle),
        Text('${(maxValue * 0.75).round()}', style: _axisLabelStyle),
        Text('${(maxValue * 0.5).round()}', style: _axisLabelStyle),
        Text('${(maxValue * 0.25).round()}', style: _axisLabelStyle),
        Text('0', style: _axisLabelStyle),
      ],
    );
  }

  Widget _buildChartContent(Map<String, int> data, int maxValue) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: LineChartPainter(
        data: data.values.toList(),
        maxValue: maxValue.toDouble(),
        lineColor: Colors.orange,
      ),
    );
  }

  Widget _buildXAxisLabels(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels
            .map((label) => Text(label, style: _axisLabelStyle))
            .toList(),
      ),
    );
  }

  TextStyle get _axisLabelStyle =>
      TextStyle(fontSize: 12, color: Colors.grey[600]);
}

/// Custom painter for the line chart
class LineChartPainter extends CustomPainter {
  final List<int> data;
  final double maxValue;
  final Color lineColor;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1).clamp(1, data.length);

    // Start fill path from bottom left
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        // Create smooth curve
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (data[i - 1] / maxValue * size.height);
        final controlX = (prevX + x) / 2;

        path.cubicTo(controlX, prevY, controlX, y, x, y);
        fillPath.cubicTo(controlX, prevY, controlX, y, x, y);
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = lineColor);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
