// File: lib/main.dart
import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/post_list_screen.dart';
import 'presentation/screens/create_post_screen.dart';
import 'presentation/screens/post_detail_screen.dart';
import 'presentation/screens/edit_post_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color kWhite = Colors.white;
    final Color kBlack = Colors.black;
    final Color kGrey = Colors.grey[200]!; // xám nhạt ~70%

    return MaterialApp(
      title: 'BlogApp',
      theme: ThemeData(
        scaffoldBackgroundColor: kWhite,
        primaryColor: kBlack,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          color: kWhite,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: kGrey, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kBlack),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kBlack, width: 2),
          ),
          fillColor: kGrey,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlack,
            foregroundColor: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: kBlack, width: 1.5),
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            padding: EdgeInsets.symmetric(vertical: 16),
            foregroundColor: kBlack,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kBlack,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kWhite,
          elevation: 0,
          iconTheme: IconThemeData(color: kBlack),
          titleTextStyle: TextStyle(
            color: kBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Roboto',
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: kWhite,
          selectedIconTheme: IconThemeData(color: kBlack, size: 28),
          unselectedIconTheme: IconThemeData(color: Colors.grey[700], size: 24),
          selectedLabelTextStyle: TextStyle(
            color: kBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
        dividerColor: kGrey,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBlack,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: kBlack),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/posts': (_) => PostListScreen(),
        '/create': (_) => CreatePostScreen(),
        '/profile': (_) => ProfileScreen(),
        '/edit': (_) => EditPostScreen(),
        '/search': (context) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Chức năng mới, xin hãy kiên nhẫn'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
            );
          });
          return Scaffold();
        },
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

        // Handle User Profile route
        if (settings.name == '/user-profile') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || args['userId'] == null || args['token'] == null) {
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    appBar: AppBar(title: Text('Error')),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Invalid user ID or missing authentication.'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  ),
            );
          }

          return MaterialPageRoute(
            builder:
                (context) => UserProfileScreen(
                  userId: args['userId'],
                  token: args['token'],
                ),
          );
        }

        return null;
      },
    );
  }
}
