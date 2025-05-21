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
  // Initialize to avoid LateInitializationError
  late Future<List<Post>> _postsFuture = Future.value([]);
  String token = ''; // Default to empty string
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTokenAndPosts();
  }

  // Load token and fetch posts initially
  Future<void> _loadTokenAndPosts() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');

    // Redirect to login if no token is available
    if (storedToken == null || storedToken.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Set token and fetch posts
    setState(() {
      token = storedToken;
    });

    _fetchPosts();
  }

  // Helper function to safely parse dates
  DateTime? _tryParseDate(String dateString) {
    if (dateString.isEmpty) {
      return null;
    }

    try {
      // Try standard ISO format
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        // Try Unix timestamp (milliseconds)
        return DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));
      } catch (_) {
        try {
          // Try Unix timestamp (seconds)
          return DateTime.fromMillisecondsSinceEpoch(
            int.parse(dateString) * 1000,
          );
        } catch (_) {
          // Could not parse the date
          return null;
        }
      }
    }
  }

  // Fetch posts from API
  void _fetchPosts() {
    if (token.isEmpty) {
      print("Cannot fetch posts: Token is empty");
      return;
    }

    final api = ApiService(http.Client());
    final repo = PostRepositoryImpl(api, token);
    setState(() {
      _postsFuture = GetAllPosts(repo).execute().then((posts) {
        // Log thông tin tối thiểu của từng post
        for (var post in posts) {
          print(
            'POST: id=[32m${post.id}[0m, text=${post.text}, author=${post.authorName}',
          );
        }
        // Sort by createdAt date (newest first) with robust date parsing
        posts.sort((a, b) {
          DateTime? dateA = _tryParseDate(a.createdAt);
          DateTime? dateB = _tryParseDate(b.createdAt);

          // If both dates are valid, compare them
          if (dateA != null && dateB != null) {
            return dateB.compareTo(dateA); // Newest first
          }
          // If only one date is valid, put the valid one first
          else if (dateA != null) {
            return -1;
          } else if (dateB != null) {
            return 1;
          }
          // If neither date is valid, don't change order
          return 0;
        });
        return posts;
      });
    });
  }

  // Pull to refresh
  Future<void> _refreshFeed() async {
    _fetchPosts();
    await _postsFuture;
  }

  // Handle navigation rail selection
  void _onNavChanged(int index) async {
    setState(() => _navIndex = index);

    switch (index) {
      case 0: // Home
        await _refreshFeed();
        break;
      case 1: // Search
        // NavigationRail handles restoring selection
        Navigator.pushNamed(context, '/search');
        break;
      case 2: // Create
        // Wait for result from CreatePostScreen
        final result = await Navigator.pushNamed(
          context,
          '/create',
          arguments: token,
        );
        if (result is bool && result) {
          // If post created successfully, refresh feed
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

  // "More" menu (Logout)
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
      backgroundColor: Colors.white,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _navIndex,
            onDestinationSelected: _onNavChanged,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.white,
            selectedIconTheme: IconThemeData(color: Colors.black, size: 28),
            unselectedIconTheme: IconThemeData(
              color: Colors.grey[700],
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
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

          // Main content (feed)
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshFeed,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts yet'));
                }

                final posts = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: _refreshFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: posts.length,
                    itemBuilder:
                        (_, i) => PostItem(
                          post: posts[i],
                          token:
                              token, // Make sure token is being passed correctly
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
