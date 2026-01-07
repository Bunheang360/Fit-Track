import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';
import '../../../core/constants/enums.dart';

/// Shows workout statistics with Days/Weeks/Months filter
class AnalyticsScreen extends StatefulWidget {
  final String userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Service for analytics business logic
  final AnalyticsService _analyticsService = AnalyticsService();

  // Current filter selection (Days, Weeks, or Months)
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.days;

  // Analytics data loaded from service
  AnalyticsData? _analyticsData;

  // Loading state
  bool _isLoading = true;

  // Chart data
  ChartData? _chartData;

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

  /// 1: Load analytics data via service
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _analyticsData = await _analyticsService.loadAnalyticsData(widget.userId);
      _updateChartData();
      setState(() => _isLoading = false);
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

  /// 2: Update chart when period changes
  void _onPeriodChanged(AnalyticsPeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
      _updateChartData();
    });
    _scrollToEnd();
  }

  /// 3: Calculate chart data via service
  void _updateChartData() {
    if (_analyticsData == null) return;

    _chartData = _analyticsService.calculateChartData(
      data: _analyticsData!,
      period: _selectedPeriod,
    );
  }

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

  /// Period Selector (Days/Weeks/Months tabs)
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

  /// Chart Display - Bar Graph Style
  Widget _buildChart() {
    final values = _chartData?.values ?? [];
    final totalExercises = _chartData?.totalExercises ?? 0;
    final maxValue = _chartData?.maxValue ?? 0;
    final chartMax = maxValue == 0 ? 5 : (maxValue + 2);

    // Days view is fixed width, weeks/months are scrollable
    final isScrollable = _selectedPeriod != AnalyticsPeriod.days;
    final barCount = values.length;

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
                  'Total: $totalExercises',
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
    final values = _chartData?.values ?? [];
    switch (_selectedPeriod) {
      case AnalyticsPeriod.days:
        return 'This week';
      case AnalyticsPeriod.weeks:
        final weeks = values.length;
        return 'Since you joined ($weeks ${weeks == 1 ? 'week' : 'weeks'})';
      case AnalyticsPeriod.months:
        final months = values.length;
        return 'Since you joined ($months ${months == 1 ? 'month' : 'months'})';
    }
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
    final values = _chartData?.values ?? [];
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  return _buildBar(
                    index,
                    maxValue,
                    constraints.maxHeight,
                    width: (constraints.maxWidth / values.length) - 8,
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
    final values = _chartData?.values ?? [];
    final value = index < values.length ? values[index] : 0;
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
        index == values.length - 1;

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
    final labels = _chartData?.labels ?? [];
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (index) {
        final isToday =
            _selectedPeriod == AnalyticsPeriod.days && index == now.weekday - 1;
        return Expanded(
          child: Text(
            labels[index],
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
    final labels = _chartData?.labels ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (index) {
        final isCurrent = index == labels.length - 1;
        return SizedBox(
          width: barWidth,
          child: Text(
            labels[index],
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
