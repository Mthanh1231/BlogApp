// File: lib/main.dart
import 'package:flutter/material.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/post_list_screen.dart';
import 'presentation/screens/create_post_screen.dart';
import 'presentation/screens/post_detail_screen.dart';
import 'presentation/screens/edit_post_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() => runApp(BlogApp());

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlogApp',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/posts': (_) => PostListScreen(),
        '/create': (_) => CreatePostScreen(),
        '/profile': (_) => ProfileScreen(),
        '/edit': (_) => EditPostScreen(),
        // We'll handle detail screen in onGenerateRoute
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          // Make sure to handle cases where arguments might be missing
          final args = settings.arguments as Map<String, dynamic>?;

          // Default values to prevent null errors
          final String postId = args?['postId'] ?? '';
          final String token = args?['token'] ?? '';

          // Show error screen if arguments are invalid
          if (postId.isEmpty) {
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    appBar: AppBar(title: Text('Error')),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Invalid post ID or missing authentication.'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/posts',
                                ),
                            child: Text('Return to Posts'),
                          ),
                        ],
                      ),
                    ),
                  ),
            );
          }

          // Create the detail screen with proper arguments
          return MaterialPageRoute(
            builder:
                (context) => PostDetailScreen(postId: postId, token: token),
          );
        }

        // Handle Edit Post route
        if (settings.name == '/edit') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => EditPostScreen(),
            settings: RouteSettings(name: '/edit', arguments: args),
          );
        }

        return null;
      },
    );
  }
}
