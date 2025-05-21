import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String token;

  const UserProfileScreen({Key? key, required this.userId, required this.token})
    : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<User>? _profileFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final api = ApiService(http.Client());
      final repo = UserRepositoryImpl(api, token: widget.token);
      final useCase = GetUserProfileUseCase(repo);

      setState(() {
        _profileFuture = useCase.execute(widget.userId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _profileFuture = Future.error('Failed to load profile: $e');
      });
      // Nếu lỗi 401 hoặc 404, xóa token và chuyển về login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Color(0xFFFED6D6),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (_isLoading ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error ?? 'No data'}'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 32, color: Colors.black),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        Text('Email', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
