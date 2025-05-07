// File: lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../widgets/loading_indicator.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
 @override _ProfileScreenState createState()=>_ProfileScreenState(); }
class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _f; late String token;
  @override void initState(){ super.initState(); _load(); }
  Future _load() async { final prefs=await SharedPreferences.getInstance(); token=prefs.getString('token')!;
    final api=ApiService(http.Client()); final repo=UserRepositoryImpl(api,token:token);
    setState(()=>_f=GetUserProfileUseCase(repo).execute('')); // blank id => backend uses token
  }
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:Text('Profile')),
    body:FutureBuilder<User>(future:_f,builder:(c,s){
      if(s.connectionState!=ConnectionState.done) return LoadingIndicator();
      if(s.hasError) return Center(child:Text('Error'));
      final u=s.data!;
      return Padding(padding:EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Name: ${u.name}'),
        Text('Email: ${u.email}'),
        Text('Nickname: ${u.nickname}'),
      ]));
    }),
  );
}
