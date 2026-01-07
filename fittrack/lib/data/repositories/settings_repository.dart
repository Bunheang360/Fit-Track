import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing app settings using SharedPreferences.
/// Handles login state and user session data.
class SettingsRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'currentUserId';
  static const String _keyUsername = 'currentUsername';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await _preferences;
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await _preferences;
      return prefs.getString(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCurrentUsername() async {
    try {
      final prefs = await _preferences;
      return prefs.getString(_keyUsername);
    } catch (e) {
      return null;
    }
  }

  Future<void> setLoggedIn(String userId, String username) async {
    try {
      final prefs = await _preferences;
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setLoggedOut() async {
    try {
      final prefs = await _preferences;
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
    } catch (e) {
      // Silently fail on logout errors
    }
  }

  /// Clears login-related settings only.
  Future<void> clear() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
    } catch (e) {
      // Silently fail on clear errors
    }
  }

  /// Clears all settings from SharedPreferences.
  Future<void> clearAll() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
    } catch (e) {
      // Silently fail
    }
  }
}
