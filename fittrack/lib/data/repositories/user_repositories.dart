// ==============================================================================
// FILE: lib/data/repositories/user_repository.dart
// UPDATED to use SQLite Database
// ==============================================================================
import '../models/user.dart';
import '../datasources/database_helper.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final users = await _db.getAllUsers();
      print('📊 Total users in database: ${users.length}');
      return users;
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// Save or update a user
  Future<void> saveUser(User user) async {
    try {
      print('');
      print('==================================================');
      print('💾 SAVING USER: ${user.name}');
      print('==================================================');

      // Validate user
      _validateUser(user);
      print('✅ User validation passed');

      // Check if user already exists
      final existingUser = await _db.getUserById(user.id);

      if (existingUser != null) {
        await _db.updateUser(user);
        print('🔄 Updated existing user');
      } else {
        await _db.insertUser(user);
        print('➕ Added new user');
      }

      print('✅ User saved successfully!');

      // Print user details
      print('');
      print('📝 USER DETAILS:');
      print('  - ID: ${user.id}');
      print('  - Name: ${user.name}');
      print('  - Email: ${user.email}');
      print('  - Age: ${user.age}');
      print('  - Gender: ${user.gender.name}');
      print('  - Weight: ${user.weight} kg');
      print('  - Height: ${user.height} cm');
      print('  - Plan: ${user.selectedPlan.name}');
      print('  - Level: ${user.selectedLevel.name}');
      print('  - Categories: ${user.selectedCategories.map((c) => c.name).join(", ")}');
      print('  - Days: ${user.selectedDays.map((d) => d.name).join(", ")}');
      print('  - Assessment Complete: ${user.hasCompletedAssessment}');
      print('==================================================');
      print('');
    } catch (e) {
      print('');
      print('❌❌❌ ERROR SAVING USER ❌❌❌');
      print('Error: $e');
      print('==================================================');
      print('');
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final user = await _db.getUserById(userId);
      if (user != null) {
        print('✅ Found user by ID: ${user.name}');
      } else {
        print('❌ User not found by ID: $userId');
      }
      return user;
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// Get user by username
  Future<User?> getUserByUsername(String username) async {
    try {
      if (username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }

      print('🔍 Searching for user: "$username"');
      final user = await _db.getUserByUsername(username);

      if (user != null) {
        print('✅ Found user: ${user.name}');
        print('  - Assessment Complete: ${user.hasCompletedAssessment}');
      } else {
        print('❌ User not found: $username');
      }

      return user;
    } catch (e) {
      print('❌ Error getting user by username: $e');
      return null;
    }
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    if (username.trim().isEmpty) return false;
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    if (email.trim().isEmpty) return false;
    final user = await _db.getUserByEmail(email);
    return user != null;
  }

  /// Validate login and return user
  Future<User?> validateLogin(String username, String password) async {
    try {
      print('🔐 Validating login for: $username');

      final user = await getUserByUsername(username);

      if (user == null) {
        print('❌ Login failed: User not found');
        return null;
      }

      if (user.password != password) {
        print('❌ Login failed: Invalid password');
        return null;
      }

      print('✅ Login successful: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Error validating login: $e');
      return null;
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _db.deleteUser(userId);
      print('✅ User deleted: $userId');
    } catch (e) {
      print('❌ Error deleting user: $e');
      rethrow;
    }
  }

  /// Clear all users
  Future<void> clearAllUsers() async {
    try {
      await _db.deleteAllUsers();
      print('✅ All users cleared');
    } catch (e) {
      print('❌ Error clearing users: $e');
      rethrow;
    }
  }

  /// Debug: Print all users
  Future<void> debugPrintAllUsers() async {
    try {
      final users = await getAllUsers();
      print('');
      print('📊 === ALL USERS (${users.length}) ===');
      for (var user in users) {
        print('  ${user.name} - ${user.email}');
        print('    Plan: ${user.selectedPlan.name}, Level: ${user.selectedLevel.name}');
        print('    Assessment: ${user.hasCompletedAssessment}');
      }
      print('=====================================');
      print('');
    } catch (e) {
      print('❌ Error printing users: $e');
    }
  }

  /// Validate user data
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