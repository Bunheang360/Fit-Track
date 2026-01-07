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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return Container(
      decoration: const BoxDecoration(color: Colors.orange),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(NavTab.home, Icons.home, 'Home', isSmall),
              _buildNavItem(
                NavTab.analytics,
                Icons.analytics,
                'Analytic',
                isSmall,
              ),
              _buildNavItem(
                NavTab.settings,
                Icons.settings,
                'Setting',
                isSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavTab tab, IconData icon, String label, bool isSmall) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: isSelected ? (isSmall ? 24 : 28) : (isSmall ? 20 : 24),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: isSmall ? 10 : 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
