import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../core/constants/enums.dart';

// ============================================================================
// SETTINGS SCREEN (Frame 23)
// ============================================================================
/// This screen shows user settings options:
/// - Profile: View user information
/// - Edit Plan: Change workout plan
/// - Change Password: Update account password
/// - Logout: Sign out of the app
class SettingsScreen extends StatelessWidget {
  // ==========================================
  // CONSTRUCTOR PARAMETERS
  // ==========================================
  final User user;
  final VoidCallback onLogout;
  final VoidCallback? onEditPlan;
  final VoidCallback? onChangePassword;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onLogout,
    this.onEditPlan,
    this.onChangePassword,
  });

  // ==========================================
  // BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTitle(),
          const SizedBox(height: 32),
          _buildProfileButton(context),
          const SizedBox(height: 12),
          _buildEditPlanButton(context),
          const SizedBox(height: 12),
          _buildChangePasswordButton(context),
          const SizedBox(height: 12),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD TITLE
  // ==========================================
  Widget _buildTitle() {
    return const Text(
      'Setting',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    );
  }

  // ==========================================
  // BUILD PROFILE BUTTON
  // ==========================================
  Widget _buildProfileButton(BuildContext context) {
    return _buildSettingButton(
      icon: Icons.person_outline,
      label: 'Profile',
      isPrimary: true,
      onTap: () => _showProfileDialog(context),
    );
  }

  // ==========================================
  // BUILD EDIT PLAN BUTTON
  // ==========================================
  Widget _buildEditPlanButton(BuildContext context) {
    return _buildSettingButton(
      icon: Icons.edit_note_outlined,
      label: 'Edit Plan',
      onTap: onEditPlan ?? () => _showComingSoon(context, 'Edit Plan'),
    );
  }

  // ==========================================
  // BUILD CHANGE PASSWORD BUTTON
  // ==========================================
  Widget _buildChangePasswordButton(BuildContext context) {
    return _buildSettingButton(
      icon: Icons.lock_outline,
      label: 'Change Password',
      onTap:
          onChangePassword ?? () => _showComingSoon(context, 'Change Password'),
    );
  }

  // ==========================================
  // BUILD LOGOUT BUTTON
  // ==========================================
  Widget _buildLogoutButton(BuildContext context) {
    return _buildSettingButton(
      icon: Icons.logout_outlined,
      label: 'Logout',
      onTap: () => _showLogoutConfirmation(context),
    );
  }

  // ==========================================
  // BUILD SETTING BUTTON (REUSABLE)
  // ==========================================
  /// Creates a styled button for settings options.
  /// isPrimary = true makes button orange, false makes it grey.
  Widget _buildSettingButton({
    required IconData icon,
    required String label,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHOW PROFILE DIALOG
  // ==========================================
  /// Displays a popup with all user information.
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Name', user.name),
            _buildProfileRow('Email', user.email),
            _buildProfileRow('Age', '${user.age} years'),
            _buildProfileRow('Weight', '${user.weight.toStringAsFixed(1)} kg'),
            _buildProfileRow('Height', '${user.height.toStringAsFixed(0)} cm'),
            _buildProfileRow('Plan', user.selectedPlan.displayName),
            _buildProfileRow('Level', user.selectedLevel.displayName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD PROFILE ROW (LABEL: VALUE)
  // ==========================================
  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // SHOW LOGOUT CONFIRMATION
  // ==========================================
  /// Asks user to confirm before logging out.
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

  // ==========================================
  // SHOW COMING SOON MESSAGE
  // ==========================================
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming soon!'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
