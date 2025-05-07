// lib/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/usecases/register_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _userCtrl     = TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  late final RegisterUserUseCase _registerUseCase;

  @override
  void initState() {
    super.initState();
    final api = ApiService(http.Client());
    _registerUseCase = RegisterUserUseCase(UserRepositoryImpl(api));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fullNameCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // Map full name -> name, email & password as usual.
      await _registerUseCase.execute(
        name: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      // Sau khi đăng ký, chuyển về login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiConfig.googleAuth);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở trình duyệt'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // nền trắng tinh, form nằm giữa
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App logo / tên
                  Text(
                    'BlogApp',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Sign up with Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 24,
                      ),
                      label: Text('Sign up with Google'),
                      onPressed: _signupWithGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email / Mobile
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'Mobile Number or Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        SizedBox(height: 12),

                        // Password
                        TextFormField(
                          controller: _passCtrl,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 6
                              ? 'Min 6 characters'
                              : null,
                        ),
                        SizedBox(height: 12),

                        // Full Name
                        TextFormField(
                          controller: _fullNameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        SizedBox(height: 12),

                        // Username
                        TextFormField(
                          controller: _userCtrl,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        SizedBox(height: 24),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Sign up'),
                          ),
                        ),

                        // Log in link
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Have an account?'),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushReplacementNamed(
                                      context, '/login'),
                              child: Text('Log in'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
