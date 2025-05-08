// File: lib/presentation/widgets/post_item.dart

import 'package:flutter/material.dart';
import '../screens/post_detail_screen.dart';
import '../../domain/entities/post.dart';
import '../../config/api_config.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final String token;

  const PostItem({required this.post, required this.token, super.key});

  String _formatDate(String dateStr) {
    try {
      // Try to parse the date string
      final date = DateTime.parse(dateStr);
      return 'Đăng vào ${date.toString().split('.').first}';
    } catch (e) {
      // If parsing fails, return the original string
      return 'Đăng vào $dateStr';
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Check if the image URL is already a full URL
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Otherwise, prepend the base URL
    return '${ApiConfig.baseUrl}$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(post.image);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: post.id, token: token),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Image if available
            if (imageUrl.isNotEmpty)
              Container(
                height: 200,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (ctx, error, stack) {
                    print('Image error in list: $error');
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.broken_image, size: 48)),
                    );
                  },
                ),
              ),

            // 2) Text if available
            if (post.text != null && post.text!.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  post.text!,
                  style: TextStyle(fontSize: 16, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // 3) Posted date
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _formatDate(post.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
