// File: lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); _check(); }
  Future _check() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Future.delayed(Duration(seconds:2));
    Navigator.pushReplacementNamed(context, token==null?'/login':'/posts', arguments: token);
  }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('BlogApp', style: TextStyle(fontSize:32))));
}