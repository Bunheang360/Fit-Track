import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Web-compatible storage handler
/// Uses SharedPreferences instead of File system
/// Works on Web, Mobile, and Desktop!
class WebStorageHandler<T> {
  final String storageKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  WebStorageHandler({
    required this.storageKey,
    required this.fromJson,
    required this.toJson,
  });

  /// Read all items from storage
  Future<List<T>> readAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('No data found for key: $storageKey');
        return [];
      }

      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading data: $e');
      return [];
    }
  }

  /// Write all items to storage
  Future<void> writeAll(List<T> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = items.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonData);
      await prefs.setString(storageKey, jsonString);
      print('Data saved to: $storageKey');
    } catch (e) {
      print('Error writing data: $e');
    }
  }

  /// Clear all data
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      print('Data cleared: $storageKey');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Check if data exists
  Future<bool> hasData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);
    return jsonString != null && jsonString.isNotEmpty;
  }
}