/// A generic result class for service operations.
/// Used to return success/failure status along with data or error messages.
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  ServiceResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  /// Creates a successful result with the given data.
  factory ServiceResult.success(T data) =>
      ServiceResult._(isSuccess: true, data: data);

  /// Creates a failure result with the given error message.
  factory ServiceResult.failure(String message) =>
      ServiceResult._(isSuccess: false, errorMessage: message);
}
