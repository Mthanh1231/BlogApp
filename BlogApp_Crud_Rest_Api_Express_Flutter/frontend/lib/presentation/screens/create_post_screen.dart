// File: lib/presentation/screens/create_post_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_config.dart';

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

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.single.bytes != null) {
      setState(() => _imageData = res.files.single.bytes);
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
      if (mounted) Navigator.pop(context, true);
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
      appBar: AppBar(
        title: const Text('Create new post'),
        centerTitle: true,
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
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel: Image picker / preview
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                color: Colors.black12,
                child:
                    _imageData == null
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_upload,
                                size: 64,
                                color: Colors.black38,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: const Text('Select from computer'),
                              ),
                            ],
                          ),
                        )
                        : Image.memory(_imageData!, fit: BoxFit.contain),
              ),
            ),
          ),

          // Right panel: Caption & location
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username placeholder
                    Row(
                      children: const [
                        CircleAvatar(child: Icon(Icons.person)),
                        SizedBox(width: 12),
                        Text(
                          'your_username',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Caption field
                    TextField(
                      controller: _captionCtrl,
                      maxLines: null,
                      maxLength: 2200,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Location field
                    TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Add location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
