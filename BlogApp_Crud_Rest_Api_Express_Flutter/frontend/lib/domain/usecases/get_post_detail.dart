// File: lib/domain/usecases/get_post_detail.dart
import '../entities/post.dart';
import '../repositories/post_repository.dart';
class GetPostDetail {
  final PostRepository repo;
  GetPostDetail(this.repo);
  Future<Post> execute(String id) => repo.getById(id);
}