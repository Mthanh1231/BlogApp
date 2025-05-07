// File: lib/domain/entities/post.dart
class Post {
  final String id;
  final String? image;
  final String? text;
  final String? address;
  final DateTime createdAt;

  Post({required this.id, this.image, this.text, this.address, required this.createdAt});
}