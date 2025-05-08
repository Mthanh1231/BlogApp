// File: lib/presentation/screens/edit_post_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/api_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/usecases/get_post_detail.dart';
import '../../domain/usecases/update_post.dart';
import '../widgets/loading_indicator.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late String token;
  late String postId;
  final _imageController = TextEditingController();
  final _textController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  late UpdatePost _updatePostUseCase;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      // Get arguments from the route
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      postId = args['id'] as String;
      token = args['token'] as String;

      // Initialize repository and use cases
      final apiService = ApiService(http.Client());
      final repository = PostRepositoryImpl(apiService, token);
      _updatePostUseCase = UpdatePost(repository);

      // Load post details
      GetPostDetail(repository)
          .execute(postId)
          .then((post) {
            _imageController.text = post.image ?? '';
            _textController.text = post.text ?? '';
            _addressController.text = post.address ?? '';
            setState(() => _isLoading = false);
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading post: $error')),
            );
            setState(() => _isLoading = false);
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSubmitting = true);

      await _updatePostUseCase.execute(postId, {
        'image': _imageController.text,
        'text': _textController.text,
        'address': _addressController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      // Return true to trigger refresh on previous screens
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          hintText: 'Enter image URL (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Text',
                          hintText: 'What\'s on your mind?',
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Text is required'
                                    : null,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Add location (optional)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
