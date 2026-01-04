import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'currentUserId';
  static const String _keyUsername = 'currentUsername';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyReminderTime = 'reminderTime';

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

  Future<int> getThemeMode() async {
    try {
      final prefs = await _preferences;
      return prefs.getInt(_keyThemeMode) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> setThemeMode(int mode) async {
    try {
      final prefs = await _preferences;
      await prefs.setInt(_keyThemeMode, mode);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await _preferences;
      return prefs.getBool(_keyNotificationsEnabled) ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await _preferences;
      await prefs.setBool(_keyNotificationsEnabled, enabled);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getReminderTime() async {
    try {
      final prefs = await _preferences;
      return prefs.getString(_keyReminderTime);
    } catch (e) {
      return null;
    }
  }

  Future<void> setReminderTime(String time) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_keyReminderTime, time);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      // Keep other app settings
    } catch (e) {
      // Silently fail on clear errors
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
    } catch (e) {
      // Silently fail
    }
  }
}
