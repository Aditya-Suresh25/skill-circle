class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter your email address';
    }

    if (!_emailPattern.hasMatch(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? strongPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Enter your password';
    }

    if (text.length < 8) {
      return 'Use at least 8 characters';
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(text);
    final hasDigit = RegExp(r'\d').hasMatch(text);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(text);

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecial) {
      return 'Use upper, lower, number, and special character';
    }

    return null;
  }
}