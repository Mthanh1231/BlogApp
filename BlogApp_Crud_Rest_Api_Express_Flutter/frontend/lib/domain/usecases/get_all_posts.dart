// File: lib/domain/usecases/get_all_posts.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';
class GetAllPosts {
  final PostRepository repo;
  GetAllPosts(this.repo);
  Future<List<Post>> execute() => repo.getAll();
}