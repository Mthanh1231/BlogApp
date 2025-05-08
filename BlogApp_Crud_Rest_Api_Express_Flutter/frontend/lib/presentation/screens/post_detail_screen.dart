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
  // Initialize with a placeholder future to avoid LateInitializationError
  Future<Post>? _postFuture;
  DeletePost? _deletePostUseCase;
  bool _isDeleting = false;
  late String _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with the token from widget
    _token = widget.token;
    // Trigger data loading after widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostData();
    });
  }

  // Function to ensure we have a valid token
  Future<bool> _ensureToken() async {
    // If token is empty or null, try to get it from SharedPreferences
    if (_token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');
      if (storedToken != null && storedToken.isNotEmpty) {
        setState(() {
          _token = storedToken;
        });
        return true;
      } else {
        // If still no token, redirect to login
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      }
    }
    return true;
  }

  void _loadPostData() async {
    setState(() {
      _isLoading = true;
    });

    // Make sure we have a token
    final hasToken = await _ensureToken();
    if (!hasToken) return;

    try {
      final api = ApiService(http.Client());
      final repo = PostRepositoryImpl(api, _token);

      // Initialize the futures
      _deletePostUseCase = DeletePost(repo);
      _postFuture = GetPostDetail(repo).execute(widget.postId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deletePost() async {
    if (_deletePostUseCase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot delete post: Not initialized')),
      );
      return;
    }

    try {
      setState(() => _isDeleting = true);

      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Delete Post'),
              content: Text('Are you sure you want to delete this post?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );

      if (shouldDelete != true) {
        setState(() => _isDeleting = false);
        return;
      }

      await _deletePostUseCase!.execute(widget.postId);

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post deleted successfully')));

      // Return true to trigger a refresh on post list screen
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
    }
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
                _isDeleting || _isLoading
                    ? null
                    : () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: {'id': widget.postId, 'token': _token},
                      );

                      // Check if we need to refresh the post list after editing
                      if (result == true) {
                        // Pop back to PostListScreen with refresh signal
                        Navigator.pop(context, true);
                      }
                    },
          ),
          IconButton(
            icon:
                _isDeleting
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Icon(Icons.delete),
            onPressed: _isDeleting || _isLoading ? null : _deletePost,
          ),
        ],
      ),
      body:
          _isLoading || _postFuture == null
              ? Center(child: LoadingIndicator())
              : FutureBuilder<Post>(
                future: _postFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done)
                    return Center(child: LoadingIndicator());

                  if (snapshot.hasError)
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error loading post: ${snapshot.error}'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPostData,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );

                  if (!snapshot.hasData)
                    return Center(child: Text('Post not found'));

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
