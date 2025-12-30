import 'dart:convert';
import 'dart:io';

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

  List<Map<String, dynamic>> read() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return [];
      }
      final contents = file.readAsStringSync();
      if (contents.isEmpty) {
        return [];
      }
      final List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  void write(List<Map<String, dynamic>> data) {
    try {
      final file = File(filePath);
      final jsonString = jsonEncode(data);
      file.writeAsStringSync(jsonString);
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

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

  // Helper methods for key-value operations
  Map<String, dynamic>? getByKey(String key) {
    final data = read();
    try {
      return data.firstWhere((item) => item['key'] == key);
    } catch (e) {
      return null;
    }
  }

  void putKeyValue(String key, dynamic value) {
    final data = read();
    final index = data.indexWhere((item) => item['key'] == key);
    if (index >= 0) {
      data[index] = {'key': key, 'value': value};
    } else {
      data.add({'key': key, 'value': value});
    }
    write(data);
  }

  bool containsKey(String key) {
    final data = read();
    return data.any((item) => item['key'] == key);
  }

  dynamic getValue(String key) {
    final item = getByKey(key);
    return item?['value'];
  }

  void deleteKey(String key) {
    final data = read();
    data.removeWhere((item) => item['key'] == key);
    write(data);
  }
}
