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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở trình duyệt')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Register',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 32),
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _userCtrl,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Vui lòng nhập tên'
                                  : null,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Vui lòng nhập email'
                                  : null,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (v) =>
                              v == null || v.length < 6
                                  ? 'Mật khẩu tối thiểu 6 ký tự'
                                  : null,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    SizedBox(height: 32),
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
                                : Text('Register'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                        child: Text('Login'),
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
