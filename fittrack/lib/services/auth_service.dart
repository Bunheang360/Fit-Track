import '../../core/models/user.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/settings_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  // Singleton pattern for consistent state across the app
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal()
    : _userRepository = UserRepository(),
      _settingsRepository = SettingsRepository();

  // For testing - allows dependency injection
  AuthService.withRepositories(this._userRepository, this._settingsRepository);

  /// LOGIN

  // Attempts to log in a user with username and password.
  // Returns [AuthResult] with success status and user data or error message.
  Future<AuthResult> login(String username, String password) async {
    try {
      // Validate input
      if (username.trim().isEmpty) {
        return AuthResult.failure('Username cannot be empty');
      }
      if (password.isEmpty) {
        return AuthResult.failure('Password cannot be empty');
      }

      // Get user by username (data access)
      final user = await _userRepository.getUserByUsername(username);

      // Validate credentials (business logic - in service layer)
      if (user == null || user.password != password) {
        return AuthResult.failure('Invalid username or password');
      }

      // Save login session
      await _settingsRepository.setLoggedIn(user.id, user.name);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Login failed. Please try again.');
    }
  }

  /// LOGOUT
  // Logs out the current user by clearing session data.
  Future<void> logout() async {
    await _settingsRepository.setLoggedOut();
  }

  /// CHECK LOGIN STATUS
  // Checks if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    return await _settingsRepository.isLoggedIn();
  }

  // Gets the currently logged-in user, if any.
  Future<User?> getCurrentUser() async {
    try {
      final userId = await _settingsRepository.getCurrentUserId();
      if (userId == null) return null;

      return await _userRepository.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  // Gets the current user's ID from session.
  Future<String?> getCurrentUserId() async {
    return await _settingsRepository.getCurrentUserId();
  }

  /// REGISTRATION VALIDATION
  // Checks if a username is available for registration.
  Future<bool> isUsernameAvailable(String username) async {
    if (username.trim().isEmpty) return false;
    return !(await _userRepository.usernameExists(username));
  }

  // Validates registration fields before proceeding to assessment.
  // Returns null if valid, or an error message if invalid.
  String? validateRegistration({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (username.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Invalid email format';
    }
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null; // Valid
  }

  /// PASSWORD MANAGEMENT
  // Changes the user's password after verifying the current password.
  Future<AuthResult> changePassword({
    required User user,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Verify current password
      if (currentPassword != user.password) {
        return AuthResult.failure('Current password is incorrect');
      }

      // Check new password is different
      if (newPassword == user.password) {
        return AuthResult.failure(
          'New password must be different from current password',
        );
      }

      // Validate new password
      if (newPassword.length < 8) {
        return AuthResult.failure('New password must be at least 8 characters');
      }

      // Update password
      final updatedUser = user.copyWith(password: newPassword);
      await _userRepository.saveUser(updatedUser);

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Failed to change password. Please try again.');
    }
  }
}

/// AUTH RESULT
// Represents the result of an authentication operation.
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
