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
    
    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'],
      image: imagePath,
      address: json['address'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'text': text,
      'image': image,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}