// File: lib/domain/usecases/create_post.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';
class CreatePost {
  final PostRepository repo;
  CreatePost(this.repo);
  Future<Post> execute(Map<String, dynamic> data) => repo.create(data);
}