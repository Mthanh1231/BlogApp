// File: lib/domain/entities/post.dart
class Post {
  final String id;
  final String userId;
  final String? text;
  final String? image;
  final String? address;
  final String createdAt;
  final String updatedAt;
  final String authorId;
  final String authorName;

  Post({
    required this.id,
    required this.userId,
    this.text,
    this.image,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorName,
  });
}
