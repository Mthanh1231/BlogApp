// lib/config/api_config.dart
import 'app_config.dart';

class ApiConfig {
  static String get baseUrl => AppConfig.apiBaseUrl ?? '';
  static const register = '/register';
  static const login = '/authenticate';
  static const posts = '/posts';
  static const userProfile = '/users';
  static const googleAuth = '/auth/google';
}
