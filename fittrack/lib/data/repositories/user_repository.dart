import '../models/user.dart';
import '../datasources/database_helper.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<User>> getAllUsers() async {
    try {
      return await _db.getAllUsers();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveUser(User user) async {
    try {
      _validateUser(user);

      final existingUser = await _db.getUserById(user.id);

      if (existingUser != null) {
        await _db.updateUser(user);
      } else {
        await _db.insertUser(user);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      return await _db.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      if (username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }
      return await _db.getUserByUsername(username);
    } catch (e) {
      return null;
    }
  }

  Future<bool> usernameExists(String username) async {
    if (username.trim().isEmpty) return false;
    final user = await getUserByUsername(username);
    return user != null;
  }

  Future<bool> emailExists(String email) async {
    if (email.trim().isEmpty) return false;
    final user = await _db.getUserByEmail(email);
    return user != null;
  }

  Future<User?> validateLogin(String username, String password) async {
    try {
      final user = await getUserByUsername(username);

      if (user == null) {
        return null;
      }

      if (user.password != password) {
        return null;
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _db.deleteUser(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllUsers() async {
    try {
      await _db.deleteAllUsers();
    } catch (e) {
      rethrow;
    }
  }

  void _validateUser(User user) {
    if (user.name.trim().isEmpty) {
      throw Exception('Username cannot be empty');
    }
    if (user.email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (user.selectedCategories.isEmpty) {
      throw Exception('At least one category must be selected');
    }
    if (user.selectedDays.isEmpty) {
      throw Exception('At least one workout day must be selected');
    }
  }
}
