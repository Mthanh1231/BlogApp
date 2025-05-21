// File: lib/presentation/screens/create_post_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/entities/user.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Uint8List? _imageData;
  final _captionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _sharing = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        final api = ApiService(http.Client());
        final repo = UserRepositoryImpl(api, token: token);
        final useCase = GetUserProfileUseCase(repo);
        final user = await useCase.execute('');
        setState(() {
          _currentUser = user;
        });
      } else {
        // Không có token, chuyển về login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Nếu lỗi 401 hoặc 404, xóa token và chuyển về login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageData = bytes);
    }
  }

  Future<void> _share() async {
    // Must have at least image or text
    if (_imageData == null && _captionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn phải thêm ảnh hoặc caption')),
      );
      return;
    }

    setState(() => _sharing = true);

    try {
      // 1) Retrieve JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')!;

      // 2) Prepare multipart request
      final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.posts);
      final req =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['text'] = _captionCtrl.text
            ..fields['address'] = _locationCtrl.text;

      // 3) Attach image file if present
      if (_imageData != null) {
        req.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageData!,
            filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      // 4) Send
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 201) {
        throw Exception('Upload failed: ${res.statusCode}\n${res.body}');
      }

      // 5) Success feedback
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã chia sẻ thành công!')));

      // 6) Return true so PostListScreen auto-refreshes
      if (mounted) {
        // Return true to indicate successful post creation
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chia sẻ: $e')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create new post'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _sharing ? null : _share,
              icon:
                  _sharing
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send, size: 18),
              label: Text(
                _sharing ? 'Sharing…' : 'Share',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final imageWidget = GestureDetector(
            onTap: _pickImage,
            child: Container(
              color: Colors.white,
              child:
                  _imageData == null
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_upload,
                              size: 64,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _imageData!,
                          fit: BoxFit.cover,
                          width: isMobile ? double.infinity : 260,
                          height: isMobile ? 220 : 320,
                        ),
                      ),
            ),
          );
          final formWidget = Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _captionCtrl,
                  decoration: InputDecoration(labelText: 'Caption'),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sharing ? null : _share,
                    child:
                        _sharing
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text('Share'),
                  ),
                ),
              ],
            ),
          );
          if (isMobile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [imageWidget, SizedBox(height: 24), formWidget],
              ),
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: imageWidget),
                Expanded(flex: 3, child: formWidget),
              ],
            );
          }
        },
      ),
    );
  }
}
