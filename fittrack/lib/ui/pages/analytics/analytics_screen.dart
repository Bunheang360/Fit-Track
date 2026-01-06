import 'package:flutter/material.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/enums.dart';

/// Shows workout statistics with Days/Weeks/Months filter
class AnalyticsScreen extends StatefulWidget {
  final String userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Database access
  final SessionRepository _sessionRepository = SessionRepository();
  final UserRepository _userRepository = UserRepository();

  // Current filter selection (Days, Weeks, or Months)
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.days;

  // All workout sessions for this user
  List<ExerciseSession> _sessions = [];

  // User registration date
  DateTime? _userRegistrationDate;

  // Loading state
  bool _isLoading = true;

  // Chart data: label (e.g., "Mon") -> workout count
  List<String> _chartLabels = [];
  List<int> _chartValues = [];

  // Total exercises done in selected period
  int _totalExercises = 0;

  // Scroll controller for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // STEP 1: Load user and sessions from database
  // ==========================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load user to get registration date
      final user = await _userRepository.getUserById(widget.userId);
      _userRegistrationDate = user?.createdAt ?? DateTime.now();

      // Load sessions
      _sessions = await _sessionRepository.getSessionsForUser(widget.userId);
      _updateChartData();
      setState(() => _isLoading = false);

      // Scroll to end for weeks/months to show latest data
      _scrollToEnd();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _selectedPeriod != AnalyticsPeriod.days) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================
  // STEP 2: Update chart when period changes
  // ==========================================
  void _onPeriodChanged(AnalyticsPeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
      _updateChartData();
    });
    _scrollToEnd();
  }

  // ==========================================
  // STEP 3: Calculate chart data based on period
  // ==========================================
  void _updateChartData() {
    // Clear old data
    _chartLabels = [];
    _chartValues = [];

    // Fill data based on selected period
    switch (_selectedPeriod) {
      case AnalyticsPeriod.days:
        _calculateDailyData();
        break;
      case AnalyticsPeriod.weeks:
        _calculateWeeklyData();
        break;
      case AnalyticsPeriod.months:
        _calculateMonthlyData();
        break;
    }

    // Calculate total
    _totalExercises = _chartValues.fold(0, (sum, val) => sum + val);
  }

  // ==========================================
  // Calculate data for each day of current week (calendar style)
  // ==========================================
  void _calculateDailyData() {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Find Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));

    // Loop through each day (Mon to Sun)
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final count = _countSessionsOnDate(day);

      _chartLabels.add(dayNames[i]);
      _chartValues.add(count);
    }
  }

  // ==========================================
  // Calculate data starting from registration week (Week 1)
  // ==========================================
  void _calculateWeeklyData() {
    final now = DateTime.now();
    final regDate = _userRegistrationDate ?? now;

    // Find Monday of registration week (Week 1)
    final regMonday = regDate.subtract(Duration(days: regDate.weekday - 1));
    final week1Start = DateTime(regMonday.year, regMonday.month, regMonday.day);

    // Find Monday of current week
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekStart = DateTime(
      currentMonday.year,
      currentMonday.month,
      currentMonday.day,
    );

    // Calculate number of weeks since registration
    final daysDiff = currentWeekStart.difference(week1Start).inDays;
    final totalWeeks = (daysDiff / 7).floor() + 1;

    // Generate data for each week
    for (int week = 0; week < totalWeeks; week++) {
      final weekStart = week1Start.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count = _countSessionsInRange(weekStart, weekEnd);

      _chartLabels.add('W${week + 1}');
      _chartValues.add(count);
    }
  }

  // ==========================================
  // Calculate data starting from registration month
  // ==========================================
  void _calculateMonthlyData() {
    final now = DateTime.now();
    final regDate = _userRegistrationDate ?? now;
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

    // Start from registration month
    int startYear = regDate.year;
    int startMonth = regDate.month;

    // End at current month
    int endYear = now.year;
    int endMonth = now.month;

    // Calculate total months
    int totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

    // Generate data for each month
    for (int i = 0; i < totalMonths; i++) {
      int year = startYear + ((startMonth - 1 + i) ~/ 12);
      int month = ((startMonth - 1 + i) % 12) + 1;

      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 1);
      final count = _countSessionsInRange(monthStart, monthEnd);

      // Show year if different from current year
      if (year != now.year) {
        _chartLabels.add("${monthNames[month - 1]}\n'${year % 100}");
      } else {
        _chartLabels.add(monthNames[month - 1]);
      }
      _chartValues.add(count);
    }
  }

  // ==========================================
  // Helper: Count sessions on a specific date
  // ==========================================
  int _countSessionsOnDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _countSessionsInRange(dayStart, dayEnd);
  }

  // ==========================================
  // Helper: Count sessions between two dates
  // ==========================================
  int _countSessionsInRange(DateTime start, DateTime end) {
    int count = 0;
    for (final session in _sessions) {
      if (session.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          session.date.isBefore(end)) {
        count++;
      }
    }
    return count;
  }

  // ==========================================
  // BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final padding = isSmall ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          // Title
          Text(
            'Analytic',
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: isSmall ? 20 : 24),

          // Period Selector (Days/Weeks/Months)
          _buildPeriodSelector(),
          SizedBox(height: isSmall ? 20 : 24),

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

  // ==========================================
  // Period Selector (Days/Weeks/Months tabs)
  // ==========================================
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
        onTap: () => _onPeriodChanged(period),
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

  // ==========================================
  // Chart Display - Bar Graph Style
  // ==========================================
  Widget _buildChart() {
    final maxValue = _findMaxValue();
    final chartMax = maxValue == 0 ? 5 : (maxValue + 2);

    // Days view is fixed width, weeks/months are scrollable
    final isScrollable = _selectedPeriod != AnalyticsPeriod.days;
    final barCount = _chartValues.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercises Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPeriodDescription(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: $_totalExercises',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                _buildYAxisLabels(chartMax),
                const SizedBox(width: 8),
                // Bars (scrollable for weeks/months)
                Expanded(
                  child: isScrollable
                      ? _buildScrollableBarChart(chartMax, barCount)
                      : _buildFixedBarChart(chartMax),
                ),
              ],
            ),
          ),
          // Scroll hint for weeks/months
          if (isScrollable && barCount > 6)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '← Swipe to see more →',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPeriodDescription() {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.days:
        return 'This week';
      case AnalyticsPeriod.weeks:
        final weeks = _chartValues.length;
        return 'Since you joined ($weeks ${weeks == 1 ? 'week' : 'weeks'})';
      case AnalyticsPeriod.months:
        final months = _chartValues.length;
        return 'Since you joined ($months ${months == 1 ? 'month' : 'months'})';
    }
  }

  // Find the highest value in chart data
  int _findMaxValue() {
    if (_chartValues.isEmpty) return 1;
    int max = _chartValues[0];
    for (final value in _chartValues) {
      if (value > max) max = value;
    }
    return max;
  }

  Widget _buildYAxisLabels(int maxValue) {
    return SizedBox(
      width: 28,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$maxValue', style: _axisLabelStyle),
          Text('${(maxValue * 0.5).round()}', style: _axisLabelStyle),
          Text('0', style: _axisLabelStyle),
        ],
      ),
    );
  }

  // Fixed bar chart for days (always 7 bars)
  Widget _buildFixedBarChart(int maxValue) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_chartValues.length, (index) {
                  return _buildBar(
                    index,
                    maxValue,
                    constraints.maxHeight,
                    width: (constraints.maxWidth / _chartValues.length) - 8,
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            _buildFixedXAxisLabels(),
          ],
        );
      },
    );
  }

  // Scrollable bar chart for weeks/months
  Widget _buildScrollableBarChart(int maxValue, int barCount) {
    const double barWidth = 50.0;
    final totalWidth = barCount * barWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth.clamp(
                    constraints.maxWidth,
                    double.infinity,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(barCount, (index) {
                      return _buildBar(
                        index,
                        maxValue,
                        constraints.maxHeight,
                        width: barWidth - 12,
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              controller: ScrollController(), // Separate controller for labels
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: totalWidth.clamp(constraints.maxWidth, double.infinity),
                child: _buildScrollableXAxisLabels(barWidth),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBar(
    int index,
    int maxValue,
    double maxHeight, {
    required double width,
  }) {
    final value = _chartValues[index];
    final barHeight = maxValue > 0
        ? (value / maxValue) *
              (maxHeight - 30) // Leave space for value label
        : 0.0;

    // Highlight today for days view
    final now = DateTime.now();
    final isToday =
        _selectedPeriod == AnalyticsPeriod.days && index == now.weekday - 1;

    // Highlight current week/month
    final isCurrent =
        (_selectedPeriod == AnalyticsPeriod.weeks ||
            _selectedPeriod == AnalyticsPeriod.months) &&
        index == _chartValues.length - 1;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Value label on top of bar
          if (value > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isToday || isCurrent
                      ? Colors.orange
                      : Colors.grey[600],
                ),
              ),
            ),
          // The bar itself
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: barHeight.clamp(4.0, maxHeight - 30),
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isToday || isCurrent
                    ? [Colors.orange.shade600, Colors.orange.shade400]
                    : [Colors.orange.shade300, Colors.orange.shade200],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              boxShadow: value > 0
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(
                          isToday || isCurrent ? 0.4 : 0.2,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedXAxisLabels() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_chartLabels.length, (index) {
        final isToday =
            _selectedPeriod == AnalyticsPeriod.days && index == now.weekday - 1;
        return Expanded(
          child: Text(
            _chartLabels[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: isToday ? Colors.orange : Colors.grey[600],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScrollableXAxisLabels(double barWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_chartLabels.length, (index) {
        final isCurrent = index == _chartLabels.length - 1;
        return SizedBox(
          width: barWidth,
          child: Text(
            _chartLabels[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? Colors.orange : Colors.grey[600],
            ),
          ),
        );
      }),
    );
  }

  TextStyle get _axisLabelStyle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
  );
}
