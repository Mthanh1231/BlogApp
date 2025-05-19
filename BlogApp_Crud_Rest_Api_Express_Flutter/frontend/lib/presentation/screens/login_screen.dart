// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/usecases/login_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  late final LoginUserUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();
    final api = ApiService(http.Client());
    _loginUseCase = LoginUserUseCase(UserRepositoryImpl(api));
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final token = await _loginUseCase.execute(
        name: _userCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pushReplacementNamed(context, '/posts', arguments: token);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    final url = Uri.parse(ApiConfig.baseUrl + ApiConfig.googleAuth);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở trình duyệt')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BlogApp',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 12),
                    ],

                    // Username
                    TextFormField(
                      controller: _userCtrl,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Vui lòng nhập tên'
                                  : null,
                      textInputAction:
                          TextInputAction.next, // Enter sẽ chuyển focus
                    ),
                    SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (v) =>
                              v == null || v.length < 6
                                  ? 'Mật khẩu tối thiểu 6 ký tự'
                                  : null,
                      textInputAction: TextInputAction.done, // Enter = done
                      onFieldSubmitted: (_) => _submit(), // Nhấn Enter submit
                    ),
                    SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child:
                            _loading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text('Login'),
                      ),
                    ),

                    // Register link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/register',
                            ),
                        child: Text('Register'),
                      ),
                    ),

                    // Divider + Google login
                    Divider(height: 32, thickness: 1),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Image.asset('assets/google_logo.png', height: 24),
                        label: Text('Login with Google'),
                        onPressed: _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
