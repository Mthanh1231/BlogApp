// File: lib/domain/usecases/register_user.dart
import '../repositories/user_repository.dart';
class RegisterUserUseCase {
  final UserRepository repo;
  RegisterUserUseCase(this.repo);
  Future<void> execute({required String name, required String password, required String email}) async {
    await repo.register({"name": name, "password": password, "email": email});
  }
}