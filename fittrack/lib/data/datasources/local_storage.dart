import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  Map<String, Map<String, dynamic>> _storage = {};
  late Directory _appDirectory;
  bool _initialized = false;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    _appDirectory = await getApplicationDocumentsDirectory();
    await _loadAllBoxes();
    _initialized = true;
  }

  Future<void> _loadAllBoxes() async {
    final storageFile = File('${_appDirectory.path}/fittrack_storage.json');
    if (await storageFile.exists()) {
      try {
        final contents = await storageFile.readAsString();
        final jsonData = jsonDecode(contents) as Map<String, dynamic>;
        _storage = jsonData.map(
          (key, value) =>
              MapEntry(key, Map<String, dynamic>.from(value as Map)),
        );
      } catch (e) {
        _storage = {};
      }
    } else {
      _storage = {};
    }
  }

  Future<void> _saveStorage() async {
    final storageFile = File('${_appDirectory.path}/fittrack_storage.json');
    await storageFile.writeAsString(jsonEncode(_storage));
  }

  StorageBox openBox(String name) {
    if (!_storage.containsKey(name)) {
      _storage[name] = {};
    }
    return StorageBox(_storage[name]!, _saveStorage);
  }
}

class StorageBox {
  final Map<String, dynamic> _data;
  final Future<void> Function() _onSave;

  StorageBox(this._data, this._onSave);

  Future<void> put(String key, dynamic value) async {
    _data[key] = value;
    await _onSave();
  }

  dynamic get(String key) {
    return _data[key];
  }

  bool containsKey(String key) {
    return _data.containsKey(key);
  }

  Future<void> delete(String key) async {
    _data.remove(key);
    await _onSave();
  }

  Future<void> clear() async {
    _data.clear();
    await _onSave();
  }

  List<String> keys() {
    return _data.keys.toList();
  }

  List<dynamic> values() {
    return _data.values.toList();
  }
}
