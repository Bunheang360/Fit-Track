import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../core/constants/enums.dart';

/// Settings Screen (Frame 23)
/// Shows Profile, Edit Plan, Change Password, and Logout options
class SettingsScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          const Text(
            'Setting',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 32),

          // Profile Button (Orange - Primary)
          _buildSettingButton(
            icon: Icons.person_outline,
            label: 'Profile',
            isPrimary: true,
            onTap: () => _showProfileDialog(context),
          ),
          const SizedBox(height: 12),

          // Edit Plan Button
          _buildSettingButton(
            icon: Icons.edit_note_outlined,
            label: 'Edit Plan',
            onTap: onEditPlan ?? () => _showComingSoon(context, 'Edit Plan'),
          ),
          const SizedBox(height: 12),

          // Change Password Button
          _buildSettingButton(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap:
                onChangePassword ??
                () => _showComingSoon(context, 'Change Password'),
          ),
          const SizedBox(height: 12),

          // Logout Button
          _buildSettingButton(
            icon: Icons.logout_outlined,
            label: 'Logout',
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

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
