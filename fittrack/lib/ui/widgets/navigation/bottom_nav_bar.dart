import 'package:flutter/material.dart';
import '../../../core/constants/enums.dart';

class BottomNavBar extends StatelessWidget {
  final NavTab selectedTab;
  final Function(NavTab) onTabSelected;

  const BottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(NavTab.home, Icons.home, 'Home'),
            _buildNavItem(NavTab.analytics, Icons.analytics, 'Analytic'),
            _buildNavItem(NavTab.settings, Icons.settings, 'Setting'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(NavTab tab, IconData icon, String label) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
