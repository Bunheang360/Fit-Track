import 'dart:convert';
import 'dart:io';

/// Generic JSON file handler - handles ONLY file operations
/// No business logic here!
class JsonFileHandler<T> {
  final String fileName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  late String filePath;

  JsonFileHandler({
    required this.fileName,
    required this.fromJson,
    required this.toJson,
  }) {
    final directory = Directory('lib/data/storage');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    filePath = '${directory.path}/$fileName';
    print('Storage path: $filePath');
  }

  /// Read all items from file
  List<T> readAll() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('File does not exist: $filePath');
        return [];
      }

      final contents = file.readAsStringSync();
      if (contents.isEmpty) {
        print('File is empty: $filePath');
        return [];
      }

      final List<dynamic> jsonData = jsonDecode(contents);
      return jsonData
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  /// Write all items to file
  void writeAll(List<T> items) {
    try {
      final file = File(filePath);
      final jsonData = items.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonData);
      file.writeAsStringSync(jsonString);
      print('Data written to: $filePath');
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  /// Clear all data
  void clear() {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        print('File cleared: $filePath');
      }
    } catch (e) {
      print('Error clearing file: $e');
    }
  }

  /// Check if file exists and has data
  bool hasData() {
    final file = File(filePath);
    if (!file.existsSync()) return false;
    final contents = file.readAsStringSync();
    return contents.isNotEmpty;
  }
}

/// Simple key-value storage for non-complex data like login status
class JsonStorage {
  final String fileName;
  late String filePath;

  JsonStorage(this.fileName) {
    final directory = Directory('lib/data/storage');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    filePath = '${directory.path}/$fileName';
  }

  /// Read all data from file as Map
  Map<String, dynamic> read() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return {};

      final contents = file.readAsStringSync();
      if (contents.isEmpty) return {};

      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      print('Error reading file: $e');
      return {};
    }
  }

  /// Write data to file
  void write(Map<String, dynamic> data) {
    try {
      final file = File(filePath);
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  /// Get a specific value by key
  String? getKeyValue(String key) {
    final data = read();
    return data[key] as String?;
  }

  /// Put a key-value pair
  void putKeyValue(String key, String value) {
    final data = read();
    data[key] = value;
    write(data);
  }

  /// Save a user (for backward compatibility)
  void saveUser(Map<String, dynamic> userData) {
    final data = read();
    final users = data['users'] as List<dynamic>? ?? [];
    users.add(userData);
    data['users'] = users;
    write(data);
  }

  /// Get all users (for backward compatibility)
  List<Map<String, dynamic>> getUsers() {
    final data = read();
    final users = data['users'] as List<dynamic>? ?? [];
    return users.map((e) => e as Map<String, dynamic>).toList();
  }

  /// Clear all data
  void clear() {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('Error clearing file: $e');
    }
  }

  /// Check if username exists
  bool usernameExists(String username) {
    final users = getUsers();
    return users.any((user) => user['name'] == username);
  }

  /// Validate login credentials
  bool validateLogin(String email, String password) {
    final users = getUsers();
    return users.any(
      (user) => user['email'] == email && user['password'] == password,
    );
  }
}
