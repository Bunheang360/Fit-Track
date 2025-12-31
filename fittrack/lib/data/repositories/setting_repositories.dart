import 'package:shared_preferences/shared_preferences.dart';

/// Model for app settings (type-safe alternative to Map)
class AppSettings {
  final bool isLoggedIn;
  final String? currentUsername;

  AppSettings({
    required this.isLoggedIn,
    this.currentUsername,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      currentUsername: json['currentUsername'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoggedIn': isLoggedIn,
      'currentUsername': currentUsername,
    };
  }

  factory AppSettings.loggedIn(String username) {
    return AppSettings(
      isLoggedIn: true,
      currentUsername: username,
    );
  }

  factory AppSettings.loggedOut() {
    return AppSettings(
      isLoggedIn: false,
      currentUsername: null,
    );
  }
}

/// Repository for app settings (Web Compatible)
/// Uses SharedPreferences instead of File system
class SettingsRepository {
  static const String _settingsKey = 'app_settings';

  /// Get current settings
  Future<AppSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return AppSettings.loggedOut();
      }

      // Parse JSON string manually (simple approach)
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final username = prefs.getString('currentUsername');

      return AppSettings(
        isLoggedIn: isLoggedIn,
        currentUsername: username,
      );
    } catch (e) {
      print('Error reading settings: $e');
      return AppSettings.loggedOut();
    }
  }

  /// Save settings
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', settings.isLoggedIn);

      if (settings.currentUsername != null) {
        await prefs.setString('currentUsername', settings.currentUsername!);
      } else {
        await prefs.remove('currentUsername');
      }

      print('Settings saved');
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }

  /// Set user as logged in
  Future<void> setLoggedIn(String username) async {
    await saveSettings(AppSettings.loggedIn(username));
    print('User logged in: $username');
  }

  /// Set user as logged out
  Future<void> setLoggedOut() async {
    await saveSettings(AppSettings.loggedOut());
    print('User logged out');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final settings = await getSettings();
    return settings.isLoggedIn;
  }

  /// Get current logged in username
  Future<String?> getCurrentUsername() async {
    final settings = await getSettings();
    return settings.currentUsername;
  }

  /// Clear all settings
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('currentUsername');
      print('Settings cleared');
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
}