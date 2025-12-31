import '../models/user.dart';
import '../datasources/web_storage_handler.dart';

/// Repository for User operations (Web Compatible)
/// Uses SharedPreferences instead of File system
class UserRepository {
  late final WebStorageHandler<User> _storageHandler;

  UserRepository() {
    _storageHandler = WebStorageHandler<User>(
      storageKey: 'users_data',
      fromJson: (json) => User.fromJson(json),
      toJson: (user) => user.toJson(),
    );
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return await _storageHandler.readAll();
  }

  /// Save or update a user
  Future<void> saveUser(User user) async {
    try {
      final users = await getAllUsers();
      print('Current users: ${users.length}');

      // Find existing user by username
      final index = users.indexWhere((u) => u.name == user.name);

      if (index >= 0) {
        // Update existing user
        users[index] = user;
        print('Updated existing user: ${user.name}');
      } else {
        // Add new user
        users.add(user);
        print('Added new user: ${user.name}');
      }

      await _storageHandler.writeAll(users);
      print('User saved successfully!');
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      final users = await getAllUsers();
      print('Searching for user: $username in ${users.length} users');

      for (var user in users) {
        if (user.name == username) {
          print('Found user: $username');
          return user;
        }
      }

      print('User not found: $username');
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Validate login credentials
  Future<bool> validateLogin(String username, String password) async {
    try {
      final user = await getUserByUsername(username);

      if (user == null) {
        print('Login failed: User not found');
        return false;
      }

      final isValid = user.password == password;
      print('Login validation for $username: $isValid');
      return isValid;
    } catch (e) {
      print('Error validating login: $e');
      return false;
    }
  }

  /// Delete user by username
  Future<void> deleteUser(String username) async {
    try {
      final users = await getAllUsers();
      users.removeWhere((u) => u.name == username);
      await _storageHandler.writeAll(users);
      print('User deleted: $username');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Clear all users
  Future<void> clearAllUsers() async {
    await _storageHandler.clear();
  }
}