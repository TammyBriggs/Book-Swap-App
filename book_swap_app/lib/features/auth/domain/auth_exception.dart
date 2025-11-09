/// Custom exception class for Firebase Authentication errors.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}