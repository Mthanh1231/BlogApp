// File: lib/domain/repositories/user_repository.dart
import '../entities/user.dart';
abstract class UserRepository {
  Future<void> register(Map<String, dynamic> userData);
  Future<String> login(Map<String, dynamic> userData);
  Future<User> getProfile(String id);
}