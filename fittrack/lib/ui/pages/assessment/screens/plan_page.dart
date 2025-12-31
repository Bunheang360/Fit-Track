import 'package:flutter/material.dart';
import '../../../widgets/assessment/question_page_wrapper.dart';
import '../../../../core/constants/enums.dart';

/// Single page for Plan selection
/// Clean, focused, reusable, and testable
class PlanPage extends StatefulWidget {
  final Plan initialPlan;
  final Function(Plan) onPlanChanged;
  final VoidCallback onNext;

  const PlanPage({
    super.key,
    required this.initialPlan,
    required this.onPlanChanged,
    required this.onNext,
  });

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late Plan _currentPlan;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.initialPlan;
  }

  @override
  Widget build(BuildContext context) {
    return QuestionPageWrapper(
      title: "Select your plan",
      onNext: widget.onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlanCard(
            'Home',
            'Workout at home with minimal equipment',
            Icons.home,
            _currentPlan == Plan.home,
            () {
              setState(() {
                _currentPlan = Plan.home;
              });
              widget.onPlanChanged(_currentPlan);
            },
          ),
          const SizedBox(height: 20),
          _buildPlanCard(
            'Gym',
            'Access to full gym equipment',
            Icons.fitness_center,
            _currentPlan == Plan.gym,
            () {
              setState(() {
                _currentPlan = Plan.gym;
              });
              widget.onPlanChanged(_currentPlan);
            },
          ),
        ],
      ),
    );
  }

  // Helper: Plan card
  Widget _buildPlanCard(
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }
}
