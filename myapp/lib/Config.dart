class Config {
  // Base URL for your authentication system
  static const String baseUrl = 'https://unamusing-hypodermically-candice.ngrok-free.dev/';
  
  // Method to get sign-in URL based on user type
  static String getSignInUrl(String userType) {
    switch (userType.toLowerCase()) {
      case 'student':
        return '$baseUrl/student/login';
      case 'teacher':
        return '$baseUrl/teacher/login';
      case 'admin':
        return '$baseUrl/admin/login';
      default:
        return '$baseUrl/login';
    }
  }
  
  // You can also add other configuration methods
  static String getSignUpUrl(String userType) {
    return getSignInUrl(userType).replaceFirst('login', 'register');
  }
}