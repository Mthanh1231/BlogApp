// File: lib/data/models/post_model.dart

import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.userId,
    super.text,
    super.image,
    super.address,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle potential different formats of image path
    String? imagePath;
    if (json['image'] != null) {
      // Check if image path is already a full URL or a relative path
      imagePath = json['image'].toString();

      // Make sure the image path doesn't contain HTML or invalid content
      if (imagePath.contains('<') || imagePath.contains('>')) {
        imagePath = null; // Invalid image path
      }
    }

    // Handle date fields from backend (might be postedAt, createdAt, or updatedAt)
    String createdAt = '';
    if (json['createdAt'] != null) {
      createdAt = json['createdAt'].toString();
    } else if (json['postedAt'] != null) {
      createdAt = json['postedAt'].toString();
    }

    String updatedAt = '';
    if (json['updatedAt'] != null) {
      updatedAt = json['updatedAt'].toString();
    } else if (json['editHistory'] != null &&
        json['editHistory'] is List &&
        json['editHistory'].isNotEmpty) {
      // If no updatedAt but has editHistory, use the latest edit date
      updatedAt = json['editHistory'].last['editedAt'].toString();
    } else {
      // Fallback to createdAt if no edit history
      updatedAt = createdAt;
    }

    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['authorId'] ?? '',
      text: json['text'],
      image: imagePath,
      address: json['address'],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'authorId': userId,
      'text': text,
      'image': image,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
