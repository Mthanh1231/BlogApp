// File: lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User>? _profileFuture;
  String? token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize loading
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');

      if (token == null) {
        // Handle missing token
        setState(() {
          _isLoading = false;
          _profileFuture = Future.error('No authentication token found');
        });
        return;
      }

      // Initialize API and repository
      final api = ApiService(http.Client());
      final repo = UserRepositoryImpl(api, token: token);
      final useCase = GetUserProfileUseCase(repo);

      // First complete the async work
      final futureToUse = useCase.execute('');

      // Then update state synchronously
      setState(() {
        _profileFuture = futureToUse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _profileFuture = Future.error('Failed to load profile: $e');
      });
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
                        'Error: ${snapshot.error}',
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
