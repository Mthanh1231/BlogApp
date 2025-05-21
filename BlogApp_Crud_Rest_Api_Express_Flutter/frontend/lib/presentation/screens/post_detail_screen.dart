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
import '../screens/edit_history_screen.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: FutureBuilder<Post>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (_isLoading || snapshot.connectionState != ConnectionState.done) {
            return Center(child: LoadingIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error ?? 'No data'}'));
          }
          final post = snapshot.data!;
          final canEdit = true; // TODO: logic xác định quyền edit
          final canDelete = true; // TODO: logic xác định quyền delete
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (post.image != null && post.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            post.image!.startsWith('http')
                                ? post.image!
                                : '${ApiConfig.baseUrl}${post.image!}',
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                post.createdAt,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      if (post.text != null && post.text!.isNotEmpty)
                        Text(post.text!, style: TextStyle(fontSize: 17)),
                      SizedBox(height: 16),
                      if (post.address != null && post.address!.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black87,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              post.address!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (canEdit)
                            ElevatedButton(
                              onPressed: () async {
                                if (post.id.isEmpty || _token.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Thiếu thông tin post hoặc token!',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/edit',
                                  arguments: {'id': post.id, 'token': _token},
                                );
                                if (result == true) {
                                  _loadPostData();
                                }
                              },
                              child: Text('Edit'),
                            ),
                          if (canDelete) SizedBox(width: 16),
                          if (canDelete)
                            OutlinedButton(
                              onPressed: _isDeleting ? null : _deletePost,
                              child:
                                  _isDeleting
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                              ),
                            ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditHistoryScreen(
                                        postId: post.id,
                                        token: _token,
                                      ),
                                ),
                              );
                            },
                            child: Text('History'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
