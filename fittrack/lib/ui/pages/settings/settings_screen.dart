import 'package:flutter/material.dart';
import '../../../core/models/user.dart';

class SettingsScreen extends StatelessWidget {
  // CONSTRUCTOR PARAMETERS
  final User user;
  final VoidCallback onLogout;
  final VoidCallback onEditPlan;
  final VoidCallback onChangePassword;
  final VoidCallback onEditProfile;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onEditPlan,
    required this.onChangePassword,
    required this.onEditProfile,
  });

  /// SHOW LOGOUT POP UP CONFIRMATION
  // Asks user to confirm before logging out.
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // BUILD UI
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
            'Setting',
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: isSmall ? 24 : 32),

          // Profile Button (Orange - Primary)
          _buildSettingButton(
            context: context,
            icon: Icons.person_outline,
            label: 'Profile',
            isPrimary: false,
            onTap: onEditProfile,
          ),
          SizedBox(height: isSmall ? 10 : 12),

          // Edit Plan Button
          _buildSettingButton(
            context: context,
            icon: Icons.edit_note_outlined,
            label: 'Edit Plan',
            onTap: onEditPlan,
          ),
          SizedBox(height: isSmall ? 10 : 12),

          // Change Password Button
          _buildSettingButton(
            context: context,
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: onChangePassword,
          ),
          SizedBox(height: isSmall ? 10 : 12),

          // Logout Button
          _buildSettingButton(
            context: context,
            icon: Icons.logout_outlined,
            label: 'Logout',
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  /// BUILD SETTING BUTTON (REUSABLE)
  // Creates a styled button for settings options. isPrimary = true makes button orange, false makes it grey.
  Widget _buildSettingButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 14 : 16,
          horizontal: isSmall ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.black87,
              size: isSmall ? 22 : 24,
            ),
            SizedBox(width: isSmall ? 12 : 16),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
