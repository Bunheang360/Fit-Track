import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'currentUserId';
  static const String _keyUsername = 'currentUsername';

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get current logged in user ID
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  /// Get current logged in username
  Future<String?> getCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername);
    } catch (e) {
      return null;
    }
  }

  /// Set user as logged in
  Future<void> setLoggedIn(String userId, String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);
    } catch (e) {
      rethrow;
    }
  }

  /// Set user as logged out
  Future<void> setLoggedOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
    } catch (e) {
      // Silently fail on logout errors
    }
  }

  /// Clear all settings
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
    } catch (e) {
      // Silently fail on clear errors
    }
  }
}
