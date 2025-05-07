// File: lib/domain/repositories/post_repository.dart
import '../entities/post.dart';
abstract class PostRepository {
  Future<List<Post>> getAll();
  Future<Post> getById(String id);
  Future<Post> create(Map<String, dynamic> data);
  Future<Post> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}
