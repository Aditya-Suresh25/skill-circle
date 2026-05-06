/// Exception for profile operations
class ProfileFailure implements Exception {
  const ProfileFailure(
    this.message, {
    this.code,
  });

  final String message;
  final String? code;

  @override
  String toString() => message;
}
