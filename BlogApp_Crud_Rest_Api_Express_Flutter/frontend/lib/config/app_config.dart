import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static String? apiBaseUrl;

  static Future<void> load() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = json.decode(configString);
    apiBaseUrl = config['api_base_url'];
  }
}
