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
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadUserProfile();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: LoadingIndicator())
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return _profileFuture == null
        ? Center(child: Text('No profile data available'))
        : FutureBuilder<User>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error: [38;5;9m${snapshot.error}[0m',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          _loadUserProfile();
                        },
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileItem('Name', user.name),
                          Divider(),
                          _buildProfileItem('Email', user.email),
                          Divider(),
                          _buildProfileItem('Nickname', user.nickname),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
