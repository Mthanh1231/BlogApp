// File: lib/domain/usecases/get_user_profile.dart
import '../entities/user.dart';
import '../repositories/user_repository.dart';
class GetUserProfileUseCase {
  final UserRepository repo;
  GetUserProfileUseCase(this.repo);
  Future<User> execute(String id) => repo.getProfile(id);
}