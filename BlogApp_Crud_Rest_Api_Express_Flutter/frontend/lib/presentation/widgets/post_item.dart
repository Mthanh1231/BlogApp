// File: lib/presentation/widgets/post_item.dart

import 'package:flutter/material.dart';
import '../screens/post_detail_screen.dart';
import '../../domain/entities/post.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final String token;

  const PostItem({
    required this.post,
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(
                postId: post.id,
                token: token,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Ảnh nếu có
            if (post.image != null && post.image!.isNotEmpty) 
              Image.network(
                post.image!,
                fit: BoxFit.cover,
                height: 300,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (ctx, error, stack) => Container(
                  height: 300,
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),

            // 2) Text nếu có
            if (post.text != null && post.text!.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  post.text!,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),

            // 3) Thời gian đăng
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                // format lại cho gọn
                'Đăng vào ${post.createdAt.toLocal().toString().split('.').first}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
