// File: lib/data/repositories/user_repository_impl.dart
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';
import '../../config/api_config.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService api;
  final String? token;

  UserRepositoryImpl(this.api, {this.token});

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    // If userData doesn't have nickname, assign name as nickname
    if (!userData.containsKey('nickname')) {
      userData['nickname'] = userData['name'];
    }

    final res = await api.post(ApiConfig.register, userData);
    if (res.statusCode != 201) {
      final message = jsonDecode(res.body)['message'] ?? '';
      throw Exception('Registration failed: $message');
    }
  }

  @override
  Future<String> login(Map<String, dynamic> userData) async {
    final res = await api.post(ApiConfig.login, userData);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['token'];
    } else {
      final message = jsonDecode(res.body)['message'] ?? '';
      throw Exception('Login failed: $message');
    }
  }

  @override
  Future<User> getProfile(String id) async {
    // Determine the endpoint to use
    final String endpoint =
        id.isEmpty
            ? '${ApiConfig.userProfile}/me' // Use /users/me endpoint for current user
            : '${ApiConfig.userProfile}/$id';

    // Log token và endpoint để debug
    print('[DEBUG] Call getProfile endpoint: ' + endpoint);
    print('[DEBUG] Token: ' + (token ?? 'NULL'));

    final res = await api.get(endpoint, token: token);

    if (res.statusCode == 200) {
      final responseBody = jsonDecode(res.body);

      // Check if the response contains user data
      if (responseBody == null) {
        throw Exception('Invalid response: null');
      }

      // Handle different response formats
      Map<String, dynamic> userData;
      if (responseBody is Map<String, dynamic>) {
        // Check if response has a 'user' field
        if (responseBody.containsKey('user')) {
          final userJson = responseBody['user'];
          if (userJson is Map<String, dynamic>) {
            userData = userJson;
          } else {
            throw Exception('User data is not a valid Map');
          }
        } else {
          // Assume the response is the user data directly
          userData = responseBody;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return UserModel.fromJson(userData);
    } else {
      final errorMsg =
          res.statusCode == 404
              ? 'User profile not found'
              : 'Failed to fetch profile: ${res.statusCode}';
      throw Exception(errorMsg);
    }
  }
}
