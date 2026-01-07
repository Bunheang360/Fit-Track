/// Utility class for common validation logic.
/// Centralizes validation rules to avoid duplication across the app.
class Validators {
  Validators._(); // Private constructor - use static methods only

  /// Validates an email address.
  /// Returns null if valid, or an error message if invalid.
  static String? validateEmail(String? email, {String emptyMessage = 'Email cannot be empty'}) {
    if (email == null || email.trim().isEmpty) {
      return emptyMessage;
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates a username.
  /// Returns null if valid, or an error message if invalid.
  static String? validateUsername(String? username, {String emptyMessage = 'Username cannot be empty'}) {
    if (username == null || username.trim().isEmpty) {
      return emptyMessage;
    }
    return null;
  }

  /// Validates a password.
  /// Returns null if valid, or an error message if invalid.
  static String? validatePassword(String? password, {
    String emptyMessage = 'Password cannot be empty',
    int minLength = 8,
  }) {
    if (password == null || password.isEmpty) {
      return emptyMessage;
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that two passwords match.
  /// Returns null if they match, or an error message if they don't.
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a name field.
  /// Returns null if valid, or an error message if invalid.
  static String? validateName(String? name, {String emptyMessage = 'Name cannot be empty'}) {
    if (name == null || name.trim().isEmpty) {
      return emptyMessage;
    }
    return null;
  }

  /// Validates registration fields.
  /// Returns null if all fields are valid, or the first error message found.
  static String? validateRegistration({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final usernameError = validateUsername(username);
    if (usernameError != null) return usernameError;

    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    final matchError = validatePasswordMatch(password, confirmPassword);
    if (matchError != null) return matchError;

    return null; // All valid
  }
}
