// File: lib/data/repositories/post_repository_impl.dart
import 'dart:convert';
import 'dart:io';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/api_service.dart';
import '../models/post_model.dart';
import '../../config/api_config.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiService api;
  final String token;

  PostRepositoryImpl(this.api, this.token);

  @override
  Future<List<Post>> getAll() async {
    final res = await api.get(ApiConfig.posts, token: token);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body)['posts'] as List;
      return list.map((e) => PostModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch posts: ${res.statusCode}');
    }
  }

  @override
  Future<Post> getById(String id) async {
    final res = await api.get('${ApiConfig.posts}/$id', token: token);
    if (res.statusCode == 200) {
      return PostModel.fromJson(jsonDecode(res.body)['post']);
    } else {
      throw Exception('Failed to fetch post: ${res.statusCode}');
    }
  }

  @override
  Future<Post> create(Map<String, dynamic> data) async {
    // Check if image is included as a File object
    if (data.containsKey('imageFile') && data['imageFile'] is File) {
      final imageFile = data['imageFile'] as File;

      // Create fields map without the image
      final fields = <String, String>{};
      data.forEach((key, value) {
        if (key != 'imageFile' && value != null) {
          fields[key] = value.toString();
        }
      });

      // Upload with multipart request
      final res = await api.uploadImage(
        ApiConfig.posts,
        imageFile,
        token: token,
        fields: fields,
      );

      if (res.statusCode == 201) {
        return PostModel.fromJson(jsonDecode(res.body)['post']);
      } else {
        throw Exception('Failed to create post with image: ${res.statusCode}');
      }
    } else {
      // Regular JSON post request without file
      final res = await api.post(ApiConfig.posts, data, token: token);
      if (res.statusCode == 201) {
        return PostModel.fromJson(jsonDecode(res.body)['post']);
      } else {
        throw Exception('Failed to create post: ${res.statusCode}');
      }
    }
  }

  @override
  Future<Post> update(String id, Map<String, dynamic> data) async {
    // Check if image is included as a File object
    if (data.containsKey('imageFile') && data['imageFile'] is File) {
      final imageFile = data['imageFile'] as File;

      // Create fields map without the image
      final fields = <String, String>{};
      data.forEach((key, value) {
        if (key != 'imageFile' && value != null) {
          fields[key] = value.toString();
        }
      });

      // Upload with multipart request
      final res = await api.uploadImage(
        '${ApiConfig.posts}/$id',
        imageFile,
        token: token,
        fields: fields,
      );

      if (res.statusCode == 200) {
        return PostModel.fromJson(jsonDecode(res.body)['post']);
      } else {
        throw Exception('Failed to update post with image: ${res.statusCode}');
      }
    } else {
      // Regular JSON put request without file
      final res = await api.put('${ApiConfig.posts}/$id', data, token: token);
      if (res.statusCode == 200) {
        return PostModel.fromJson(jsonDecode(res.body)['post']);
      } else {
        throw Exception('Failed to update post: ${res.statusCode}');
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    final res = await api.deleteReq('${ApiConfig.posts}/$id', token: token);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete post: ${res.statusCode}');
    }
  }
}
