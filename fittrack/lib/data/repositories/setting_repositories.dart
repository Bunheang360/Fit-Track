// ==============================================================================
// FILE: lib/data/repositories/settings_repository.dart
// Simple settings using SharedPreferences (works everywhere)
// ==============================================================================
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'currentUserId';
  static const String _keyUsername = 'currentUsername';

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      print('🔍 Login status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  /// Get current logged in user ID
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      print('🔍 Current user ID: $userId');
      return userId;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Get current logged in username
  Future<String?> getCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_keyUsername);
      print('🔍 Current username: $username');
      return username;
    } catch (e) {
      print('❌ Error getting username: $e');
      return null;
    }
  }

  /// Set user as logged in
  Future<void> setLoggedIn(String userId, String username) async {
    try {
      print('');
      print('==================================================');
      print('🔐 LOGGING IN USER');
      print('==================================================');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);

      print('✅ User logged in successfully');
      print('  - User ID: $userId');
      print('  - Username: $username');
      print('==================================================');
      print('');
    } catch (e) {
      print('❌ Error setting login: $e');
      rethrow;
    }
  }

  /// Set user as logged out
  Future<void> setLoggedOut() async {
    try {
      print('🚪 Logging out user');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);

      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  /// Clear all settings
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      print('✅ Settings cleared');
    } catch (e) {
      print('❌ Error clearing settings: $e');
    }
  }

  /// Debug: Print current settings
  Future<void> debugPrintSettings() async {
    try {
      print('');
      print('⚙️ === CURRENT SETTINGS ===');
      print('  IsLoggedIn: ${await isLoggedIn()}');
      print('  UserId: ${await getCurrentUserId()}');
      print('  Username: ${await getCurrentUsername()}');
      print('============================');
      print('');
    } catch (e) {
      print('❌ Error printing settings: $e');
    }
  }
}