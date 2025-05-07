// File: lib/data/datasources/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
class ApiService {
  final http.Client client;
  ApiService(this.client);
  Future<http.Response> post(String path, Map<String, dynamic> body, {String? token}) {
    return client.post(Uri.parse(ApiConfig.baseUrl + path), headers: _headers(token), body: jsonEncode(body));
  }
  Future<http.Response> get(String path, {String? token}) {
    return client.get(Uri.parse(ApiConfig.baseUrl + path), headers: _headers(token));
  }
  Future<http.Response> put(String path, Map<String, dynamic> body, {String? token}) {
    return client.put(Uri.parse(ApiConfig.baseUrl + path), headers: _headers(token), body: jsonEncode(body));
  }
  Future<http.Response> deleteReq(String path, {String? token}) {
    return client.delete(Uri.parse(ApiConfig.baseUrl + path), headers: _headers(token));
  }
  Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
}