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
        '/detail':
            (_) => PostDetailScreen(
              postId: '', // These will be overridden by arguments
              token: '',
            ),
      },
      onGenerateRoute: (settings) {
        // This is needed to handle route arguments properly
        if (settings.name == '/detail') {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder:
                (context) => PostDetailScreen(
                  postId: args['postId'],
                  token: args['token'],
                ),
          );
        }
        return null;
      },
    );
  }
}
