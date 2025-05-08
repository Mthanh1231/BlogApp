// File: lib/presentation/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_post_detail.dart';
import '../../domain/usecases/delete_post.dart';
import '../widgets/loading_indicator.dart';
import '../../config/api_config.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String token;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.token,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _postFuture;
  late DeletePost _deletePostUseCase;

  @override
  void initState() {
    super.initState();
    final api = ApiService(http.Client());
    final repo = PostRepositoryImpl(api, widget.token);
    _postFuture = GetPostDetail(repo).execute(widget.postId);
    _deletePostUseCase = DeletePost(repo);
  }

  Future _deletePost() async {
    await _deletePostUseCase.execute(widget.postId);
    Navigator.pop(context);
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return SizedBox(); // Return empty box if no image
    }

    // Check if the image URL is already a full URL
    final fullImageUrl =
        imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiConfig.baseUrl}$imageUrl';

    return Container(
      height: 250,
      width: double.infinity,
      child: Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Handle image loading errors
          print('Image error: $error');
          return Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: Text('Image not available'),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  '/edit',
                  arguments: {'id': widget.postId, 'token': widget.token},
                ),
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: _deletePost),
        ],
      ),
      body: FutureBuilder<Post>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return LoadingIndicator();

          if (snapshot.hasError)
            return Center(child: Text('Error loading post: ${snapshot.error}'));

          final post = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(post.image),
                  SizedBox(height: 16),
                  if (post.text != null && post.text!.isNotEmpty)
                    Text(post.text!, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  if (post.address != null && post.address!.isNotEmpty)
                    Text(
                      post.address!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Created: ${post.createdAt}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
