// File: lib/presentation/screens/edit_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/api_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_post_detail.dart';
import '../../domain/usecases/update_post.dart';
import '../widgets/loading_indicator.dart';
import '../../config/api_config.dart';

class EditPostScreen extends StatefulWidget {
  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _addressController = TextEditingController();

  String? _token;
  String? _postId;
  Post? _post;
  File? _image;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _imageUrl;
  String? _debugLog;

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for reading route parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostData();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadPostData() async {
    try {
      setState(() => _isLoading = true);

      // Extract route arguments
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      _postId = args['id'];
      _token = args['token'];

      // Fallback to SharedPreferences if token is missing
      if (_token == null || _token!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('token');

        if (_token == null || _token!.isEmpty) {
          // No token available, redirect to login
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      }

      // Log giá trị token và postId sau khi load
      _debugLog =
          'DEBUG: Sau khi load, _token=[32m[1m${_token}[0m, _postId=${_postId}';
      print(_debugLog);

      // Nếu vẫn thiếu token hoặc postId, báo lỗi và return
      if (_token == null ||
          _token!.isEmpty ||
          _postId == null ||
          _postId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chỉnh sửa: thiếu token hoặc postId!'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Fetch post data
      final api = ApiService(http.Client());
      final repo = PostRepositoryImpl(api, _token!);
      _post = await GetPostDetail(repo).execute(_postId!);

      // Populate form fields
      _textController.text = _post?.text ?? '';
      _addressController.text = _post?.address ?? '';
      _imageUrl = _post?.image;

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading post data: $e');
      setState(() => _isLoading = false);

      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load post: $e')));
    }
  }

  Future<void> _pickImage() async {
    // Using built-in file picker instead of image_picker
    try {
      // Platform-specific file picking can be implemented here
      // For now, showing a message about the missing package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image picker functionality not available')),
      );
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _updatePost() async {
    if (_isLoading || _post == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng đợi dữ liệu tải xong!')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thiếu token!')));
      return;
    }
    if (_postId == null || _postId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thiếu postId!')));
      return;
    }
    if (_post!.id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post không hợp lệ!')));
      return;
    }
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Caption không được để trống!')));
      return;
    }
    try {
      setState(() => _isSaving = true);
      final api = ApiService(http.Client());
      final repo = PostRepositoryImpl(api, _token!);
      final updatePost = UpdatePost(repo);
      Map<String, dynamic> updatedData = {};
      if (_textController.text.trim() != (_post?.text ?? '')) {
        updatedData['text'] = _textController.text.trim();
      }
      if (_addressController.text.trim() != (_post?.address ?? '')) {
        updatedData['address'] = _addressController.text.trim();
      }
      if (updatedData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không có thay đổi nào để cập nhật!')),
        );
        setState(() => _isSaving = false);
        return;
      }
      // Log chi tiết trước khi update
      print(
        'DEBUG: _postId=$_postId, _token=$_token, updatedData=$updatedData, _post.id=${_post?.id}',
      );
      if (_postId == null || _postId!.isEmpty) {
        print('ERROR: _postId is null or empty');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thiếu postId!')));
        setState(() => _isSaving = false);
        return;
      }
      if (_post == null || _post!.id.isEmpty) {
        print('ERROR: _post is null or id is empty');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post không hợp lệ!')));
        setState(() => _isSaving = false);
        return;
      }
      // Log dữ liệu gửi lên backend
      print(
        'DEBUG UPDATE: _postId=$_postId, updatedData=$updatedData, token=$_token',
      );
      await updatePost.execute(_postId!, updatedData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post updated successfully')));
      Navigator.pop(context, true);
    } catch (e, stack) {
      print('Error updating post: $e');
      print('STACK: $stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
      setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    // Bỏ hoàn toàn phần upload/chọn ảnh trong update post
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit post'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _textController,
                      decoration: InputDecoration(labelText: 'Caption'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Caption không được để trống!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_isSaving || _isLoading || _post == null)
                                ? null
                                : _updatePost,
                        child:
                            _isSaving
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text('Save'),
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
