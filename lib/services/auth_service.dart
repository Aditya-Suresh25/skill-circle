class AuthService {
  // Hardcoded test credentials
  static const String testEmail = 'luffy123@gmail.com';
  static const String testPassword = 'luffy12345';
  static const String testUsername = 'Luffy';

  /// Validates login credentials
  /// Returns username if valid, null if invalid
  static String? validateLogin(String email, String password) {
    if (email.trim() == testEmail && password == testPassword) {
      return testUsername;
    }
    return null;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    // TODO: Implement with proper session/token management
    return false;
  }

  /// Logout user
  static Future<void> logout() async {
    // TODO: Implement logout logic
  }
}
