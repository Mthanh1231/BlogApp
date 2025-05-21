// The updated PostItem widget with proper navigation handling
// File: lib/presentation/widgets/post_item.dart

import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../config/api_config.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final String token;
  final VoidCallback onPostDeleted;

  const PostItem({
    Key? key,
    required this.post,
    required this.token,
    required this.onPostDeleted,
  }) : super(key: key);

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    return imageUrl.startsWith('http')
        ? imageUrl
        : '${ApiConfig.baseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          // Navigate to detail screen with proper arguments
          final result = await Navigator.pushNamed(
            context,
            '/detail',
            arguments: {'postId': post.id, 'token': token},
          );

          // If result is true, post was edited or deleted, refresh the list
          if (result == true) {
            onPostDeleted();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.image != null && post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  _getImageUrl(post.image),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, error, __) => Container(
                        height: 100,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/user-profile',
                        arguments: {'userId': post.authorId, 'token': token},
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            post.authorName.isNotEmpty
                                ? post.authorName[0].toUpperCase()
                                : '?',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  if (post.text != null && post.text!.isNotEmpty)
                    Text(
                      post.text!,
                      style: TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 10),
                  if (post.address != null && post.address!.isNotEmpty)
                    Text(
                      post.address!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  SizedBox(height: 6),
                  Text(
                    post.createdAt,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
