// File: lib/data/models/post_model.dart

import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required String id,
    required String userId,
    String? text,
    String? image,
    String? address,
    required String createdAt,
    required String updatedAt,
    required String authorId,
    required String authorName,
  }) : super(
         id: id,
         userId: userId,
         text: text,
         image: image,
         address: address,
         createdAt: createdAt,
         updatedAt: updatedAt,
         authorId: authorId,
         authorName: authorName,
       );

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

    // Xử lý trường hợp author là object hoặc string
    String userId = '';
    String authorId = '';
    String authorName = 'Unknown';
    if (json['author'] is Map) {
      userId = json['author']['_id']?.toString() ?? '';
      authorId = json['author']['_id']?.toString() ?? '';
      authorName = json['author']['name'] ?? 'Unknown';
    } else if (json['author'] is String) {
      authorName = json['author'];
    }

    return PostModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: userId,
      text: json['text'],
      image: imagePath,
      address: json['address'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      authorId: authorId,
      authorName: authorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'authorId': authorId,
      'text': text,
      'image': image,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
