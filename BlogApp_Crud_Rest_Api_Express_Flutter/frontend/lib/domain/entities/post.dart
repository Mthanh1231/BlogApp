// File: lib/domain/entities/post.dart
class Post {
  final String id;
  final String userId;
  final String? text;
  final String? image;
  final String? address;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.userId,
    this.text,
    this.image,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}
