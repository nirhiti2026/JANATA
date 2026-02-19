/// Utility class for formatting Firebase error messages into user-friendly messages
class FirebaseErrorFormatter {
  static String formatAuthError(dynamic error) {
    final message = error.toString().toLowerCase();

    // Email/Password errors
    if (message.contains('user-not-found') || message.contains('invalid-email')) {
      return 'Email address not found. Please check and try again.';
    }
    if (message.contains('wrong-password') || message.contains('incorrect') || message.contains('malformed') || message.contains('supplied auth credential')) {
      return 'Incorrect password. Please try again.';
    }
    if (message.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters with mix of letters and numbers.';
    }
    if (message.contains('email-already-in-use')) {
      return 'This email is already registered. Please login or use a different email.';
    }
    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('too-many-requests')) {
      return 'Too many failed login attempts. Please try again later.';
    }
    if (message.contains('configuration-not-found')) {
      return 'Authentication not properly configured. Please contact support.';
    }
    if (message.contains('operation-not-allowed')) {
      return 'This operation is not allowed. Please contact support.';
    }

    // Firestore errors
    if (message.contains('permission-denied')) {
      return 'You do not have permission to perform this action.';
    }
    if (message.contains('not-found')) {
      return 'The requested data was not found.';
    }
    if (message.contains('already-exists')) {
      return 'This data already exists.';
    }
    if (message.contains('failed-precondition')) {
      return 'Operation failed. Please try again.';
    }
    if (message.contains('aborted')) {
      return 'Operation was aborted. Please try again.';
    }
    if (message.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    if (message.contains('deadline-exceeded')) {
      return 'Operation took too long. Please try again.';
    }

    // Network errors
    if (message.contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // Generic error
    if (error.toString().isNotEmpty) {
      // Extract just the meaningful part
      String errorMsg = error.toString();
      if (errorMsg.contains(']')) {
        errorMsg = errorMsg.split(']').last.trim();
      }
      return errorMsg.isEmpty ? 'An error occurred. Please try again.' : errorMsg;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static String formatPasswordError(String error) {
    if (error.contains('too weak')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (error.contains('not match')) {
      return 'Passwords do not match.';
    }
    if (error.contains('required')) {
      return 'Password is required.';
    }
    if (error.contains('current')) {
      return 'Current password is incorrect.';
    }
    return error;
  }

  static String formatProfileError(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission-denied')) {
      return 'You do not have permission to update this profile.';
    }
    if (message.contains('not-found')) {
      return 'Profile not found.';
    }
    return 'Failed to update profile. Please try again.';
  }
}
