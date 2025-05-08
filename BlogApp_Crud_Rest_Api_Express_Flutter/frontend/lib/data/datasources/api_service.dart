// File: lib/data/datasources/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';

class ApiService {
  final http.Client client;

  ApiService(this.client);

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return client.post(
      Uri.parse(ApiConfig.baseUrl + path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path, {String? token}) {
    return client.get(
      Uri.parse(ApiConfig.baseUrl + path),
      headers: _headers(token),
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return client.put(
      Uri.parse(ApiConfig.baseUrl + path),
      headers: _headers(token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteReq(String path, {String? token}) {
    return client.delete(
      Uri.parse(ApiConfig.baseUrl + path),
      headers: _headers(token),
    );
  }

  Future<http.Response> uploadImage(
    String path,
    File imageFile, {
    String? token,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse(ApiConfig.baseUrl + path);
    final request = http.MultipartRequest('POST', uri);

    // Add headers including auth token
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add text fields if provided
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Detect mime type based on file extension
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final mimeType = _getMimeType(fileExtension);

    // Add the image file
    request.files.add(
      http.MultipartFile(
        'image',
        imageFile.readAsBytes().asStream(),
        await imageFile.length(),
        filename: 'image.$fileExtension',
        contentType: MediaType('image', mimeType),
      ),
    );

    // Send the request
    final streamedResponse = await request.send();

    // Convert to a regular response
    return await http.Response.fromStream(streamedResponse);
  }

  Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg'; // Default to jpeg
    }
  }
}
