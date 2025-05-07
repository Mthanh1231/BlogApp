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
  // Nếu userData không có nickname, tự gán = name
  if (!userData.containsKey('nickname')) {
    userData['nickname'] = userData['name'];
  }
  final res = await api.post(ApiConfig.register, userData);
  if (res.statusCode != 201) {
    throw Exception(
      'Registration failed: ' +
      (jsonDecode(res.body)['message'] ?? '')
    );
  }
}
  @override
  Future<String> login(Map<String, dynamic> userData) async {
    final res = await api.post(ApiConfig.login, userData);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['token'];
    } else {
      throw Exception('Login failed: ' + (jsonDecode(res.body)['message'] ?? ''));
    }
  }
  @override
  Future<User> getProfile(String id) async {
    final res = await api.get('${ApiConfig.userProfile}/$id', token: token);
    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body)['user']);
    } else {
      throw Exception('Fetch profile failed');
    }
  }
}