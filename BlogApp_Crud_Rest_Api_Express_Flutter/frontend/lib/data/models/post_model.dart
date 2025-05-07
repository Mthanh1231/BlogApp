import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    super.image,
    super.text,
    super.address,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      // Bảo vệ null với giá trị mặc định
      id: (json['_id'] as String?) ?? '',
      image: json['image'] as String?,
      text: json['text'] as String? ?? '',
      address: json['address'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')
              ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'text': text,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
