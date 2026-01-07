import '../core/models/user.dart';
import '../core/models/service_result.dart';
import '../core/utils/validators.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../core/constants/enums.dart';

/// Type alias for user operations that return a User on success.
typedef UserResult = ServiceResult<User>;

class UserService {
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  // Singleton pattern
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal()
    : _userRepository = UserRepository(),
      _settingsRepository = SettingsRepository();

  // For testing
  UserService.withRepositories(this._userRepository, this._settingsRepository);

  // CREATE USER (After Assessment)

  // Creates a new user after completing the assessment.
  // Returns UserResult with success status and user data.
  Future<UserResult> createUser({
    required String username,
    required String email,
    required String password,
    required int age,
    required Gender gender,
    required double weight,
    required double height,
    required Plan selectedPlan,
    required Level selectedLevel,
    required List<Categories> selectedCategories,
    required List<DayOfWeek> selectedDays,
  }) async {
    try {
      // Validate required fields
      if (selectedCategories.isEmpty) {
        return UserResult.failure('Please select at least one category');
      }
      if (selectedDays.isEmpty) {
        return UserResult.failure('Please select at least one workout day');
      }

      // Create user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: username.trim(),
        email: email.trim(),
        password: password,
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        selectedPlan: selectedPlan,
        selectedLevel: selectedLevel,
        selectedCategories: selectedCategories,
        selectedDays: selectedDays,
        hasCompletedAssessment: true,
      );

      // Save to database
      await _userRepository.saveUser(user);

      // Log in the user
      await _settingsRepository.setLoggedIn(user.id, user.name);

      return UserResult.success(user);
    } catch (e) {
      return UserResult.failure('Failed to create account. Please try again.');
    }
  }

  /// GET USER
  // Gets a user by their ID.
  Future<User?> getUserById(String userId) async {
    return await _userRepository.getUserById(userId);
  }

  /// UPDATE PROFILE
  // Updates user profile information.
  Future<UserResult> updateProfile({
    required User currentUser,
    required String name,
    required String email,
    required int age,
    required double weight,
    required double height,
    required Level level,
  }) async {
    try {
      // Validate
      final nameError = Validators.validateName(name);
      if (nameError != null) return UserResult.failure(nameError);

      final emailError = Validators.validateEmail(email);
      if (emailError != null) return UserResult.failure(emailError);

      // Update user
      final updatedUser = currentUser.copyWith(
        name: name.trim(),
        email: email.trim(),
        age: age,
        weight: weight,
        height: height,
        selectedLevel: level,
      );

      await _userRepository.saveUser(updatedUser);

      return UserResult.success(updatedUser);
    } catch (e) {
      return UserResult.failure('Failed to update profile. Please try again.');
    }
  }

  /// UPDATE WORKOUT PLAN
  // Updates user's workout plan, categories, and schedule.
  Future<UserResult> updateWorkoutPlan({
    required User currentUser,
    required Plan plan,
    required List<Categories> categories,
    required List<DayOfWeek> days,
  }) async {
    try {
      // Validate
      if (categories.isEmpty) {
        return UserResult.failure('Please select at least one category');
      }
      if (days.isEmpty) {
        return UserResult.failure('Please select at least one workout day');
      }

      // Update user
      final updatedUser = currentUser.copyWith(
        selectedPlan: plan,
        selectedCategories: categories,
        selectedDays: days,
      );

      await _userRepository.saveUser(updatedUser);

      return UserResult.success(updatedUser);
    } catch (e) {
      return UserResult.failure('Failed to update plan. Please try again.');
    }
  }
}
