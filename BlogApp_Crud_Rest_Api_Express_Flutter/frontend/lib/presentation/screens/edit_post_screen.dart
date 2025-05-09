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
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSaving = true);

      final api = ApiService(http.Client());
      final repo = PostRepositoryImpl(api, _token!);
      final updatePost = UpdatePost(repo);

      // Prepare update data
      Map<String, dynamic> updatedData = {
        'text': _textController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Add image if selected
      if (_image != null) {
        updatedData['imageFile'] = _image;
      }

      // Update post
      await updatePost.execute(_postId!, updatedData);

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post updated successfully')));

      // Return to posts list with refresh signal
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating post: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
      setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    if (_image != null) {
      // Show selected local image
      return Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_image!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _image = null),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Show existing image from URL
      final fullImageUrl =
          _imageUrl!.startsWith('http')
              ? _imageUrl!
              : '${ApiConfig.baseUrl}$_imageUrl';

      return Stack(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(
              fullImageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text('Image not available'),
                  ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _imageUrl = null),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      );
    } else {
      // No image
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(icon: const Icon(Icons.save), onPressed: _updatePost),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview
                      _buildImagePreview(),
                      const SizedBox(height: 16),

                      // Image Picker Button
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text('Change Image'),
                      ),
                      const SizedBox(height: 24),

                      // Post Text Field
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Post Text',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        enabled: !_isSaving,
                      ),
                      const SizedBox(height: 16),

                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        enabled: !_isSaving,
                      ),
                      const SizedBox(height: 24),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _updatePost,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('UPDATE POST'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
