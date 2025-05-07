// File: lib/domain/usecases/login_user.dart
import '../repositories/user_repository.dart';
class LoginUserUseCase {
  final UserRepository repo;
  LoginUserUseCase(this.repo);
  Future<String> execute({required String name, required String password}) async {
    return await repo.login({"name": name, "password": password});
  }
}