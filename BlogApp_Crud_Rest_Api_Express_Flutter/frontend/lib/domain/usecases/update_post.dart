// File: lib/domain/usecases/update_post.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';
class UpdatePost {
  final PostRepository repo;
  UpdatePost(this.repo);
  Future<Post> execute(String id, Map<String, dynamic> data) => repo.update(id, data);
}