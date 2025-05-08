// File: lib/presentation/widgets/post_item.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/post.dart';
import '../../config/api_config.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final String token;
  final VoidCallback onPostDeleted; // Add callback function

  const PostItem({
    Key? key,
    required this.post,
    required this.token,
    required this.onPostDeleted, // Required parameter
  }) : super(key: key);

  // Format date to be more readable
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        // Format as date if older than a week
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        // Days ago
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        // Hours ago
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        // Minutes ago
        return '${difference.inMinutes} minutes ago';
      } else {
        // Just now
        return 'Just now';
      }
    } catch (e) {
      // Fallback if date can't be parsed
      return dateString;
    }
  }

  // Delete post function
  Future<void> _deletePost(BuildContext context) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    try {
      // Make API call to delete post
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.posts}/${post.id}',
      );
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );

        // Call the callback to refresh the post list
        onPostDeleted();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: ${response.body}')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, UserID, Location, and Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar placeholder
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                // User ID and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User: ${post.userId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (post.address != null && post.address!.isNotEmpty)
                        Text(
                          post.address!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions menu (more options)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePost(context);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                ),
              ],
            ),
          ),

          // Image (if available)
          if (post.image != null && post.image!.isNotEmpty)
            Image.network(
              post.image!.startsWith('http')
                  ? post.image!
                  : '${ApiConfig.baseUrl}${post.image}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, size: 48, color: Colors.grey),
                  ),
                );
              },
            ),

          // Caption/Text
          if (post.text != null && post.text!.isNotEmpty)
            Padding(padding: const EdgeInsets.all(12), child: Text(post.text!)),

          // Footer: Like, Comment, Date
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Like button
                const Icon(Icons.favorite_border),
                const SizedBox(width: 8),
                const Text('Like'),
                const SizedBox(width: 16),
                // Comment button
                const Icon(Icons.comment_outlined),
                const SizedBox(width: 8),
                const Text('Comment'),
                const Spacer(),
                // Date/time
                Text(
                  _formatDate(post.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
