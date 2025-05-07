// File: lib/domain/usecases/delete_post.dart
import '../repositories/post_repository.dart';
class DeletePost {
  final PostRepository repo;
  DeletePost(this.repo);
  Future<void> execute(String id) => repo.delete(id);
}