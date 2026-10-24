class ApiConstants {
  ApiConstants._();

  /// For Android Emulator:
  /// 10.0.2.2 points to your computer's localhost.
  ///
  /// Example:
  /// NestJS -> http://localhost:3000
  /// Flutter Emulator -> http://10.0.2.2:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.2.22.146:3000',
  );

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String currentUser = '/auth/me';
  static const String profilePhoto = '/auth/me/profile-photo';
  static const String photoRecords = '/auth/photos';

  static String photoImage(int id) => '/auth/photos/$id/image';
}
