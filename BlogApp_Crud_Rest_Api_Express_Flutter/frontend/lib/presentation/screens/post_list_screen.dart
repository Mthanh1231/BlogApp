//file: post_list_screen.dart
// File: lib/presentation/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/usecases/get_all_posts.dart';
import '../../domain/entities/post.dart';
import '../widgets/post_item.dart';
import '../widgets/loading_indicator.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // Khởi tạo tránh LateInitializationError
  late Future<List<Post>> _postsFuture = Future.value([]);
  String? token;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTokenAndPosts();
  }

  // Load token và fetch lần đầu
  Future<void> _loadTokenAndPosts() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _fetchPosts();
  }

  // Hàm gọi API để fetch posts
  void _fetchPosts() {
    final api = ApiService(http.Client());
    final repo = PostRepositoryImpl(api, token!);
    setState(() {
      _postsFuture = GetAllPosts(repo).execute().then((posts) {
        // Improved sorting by createdAt date (newest first)
        posts.sort((a, b) {
          try {
            DateTime dateA = DateTime.parse(a.createdAt);
            DateTime dateB = DateTime.parse(b.createdAt);
            return dateB.compareTo(dateA); // Newest first
          } catch (e) {
            // Fallback if dates can't be parsed
            print('Error sorting dates: $e');
            return 0;
          }
        });
        return posts;
      });
    });
  }

  // Refresh khi kéo thả
  Future<void> _refreshFeed() async {
    _fetchPosts();
    await _postsFuture;
  }

  // Xử lý chọn nút NavigationRail
  void _onNavChanged(int index) async {
    setState(() => _navIndex = index);

    switch (index) {
      case 0: // Home
        await _refreshFeed();
        break;
      case 1: // Search
        Navigator.pushNamed(context, '/search');
        break;
      case 2: // Create
        // Đợi kết quả từ CreatePostScreen
        final result = await Navigator.pushNamed(
          context,
          '/create',
          arguments: token,
        );
        if (result is bool && result) {
          // nếu share thành công, refresh feed
          await _refreshFeed();
        }
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
      case 4: // More
        _showMoreMenu();
        break;
    }
  }

  // Menu "More" (Logout)
  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Cột điều hướng dọc
          NavigationRail(
            selectedIndex: _navIndex,
            onDestinationSelected: _onNavChanged,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.create),
                label: Text('Create'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.more_horiz),
                label: Text('More'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Phần nội dung chính (feed)
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                final posts = snapshot.data!;
                if (posts.isEmpty) {
                  return const Center(child: Text('Bạn chưa có bài viết nào'));
                }
                return RefreshIndicator(
                  onRefresh: _refreshFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: posts.length,
                    itemBuilder:
                        (_, i) => PostItem(
                          post: posts[i],
                          token: token!,
                          onPostDeleted: _refreshFeed, // Pass refresh callback
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
