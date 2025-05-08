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
        '/edit': (_) => EditPostScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}
