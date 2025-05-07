// File: lib/presentation/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_post_detail.dart';
import '../../domain/usecases/delete_post.dart';
import '../widgets/loading_indicator.dart';
class PostDetailScreen extends StatefulWidget {
  final String postId; final String token;
  const PostDetailScreen({super.key, required this.postId, required this.token});
  @override _PostDetailScreenState createState()=>_PostDetailScreenState();
}
class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _f;
  late DeletePost ucDel;
  @override void initState(){ super.initState(); final api=ApiService(http.Client()); final repo=PostRepositoryImpl(api,widget.token);
    _f=GetPostDetail(repo).execute(widget.postId); ucDel=DeletePost(repo);
  }
  Future _del() async { await ucDel.execute(widget.postId); Navigator.pop(context); }
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:Text('Detail'),actions:[IconButton(icon:Icon(Icons.edit),onPressed:()=>Navigator.pushNamed(c,'/edit',arguments:{'id':widget.postId,'token':widget.token})),IconButton(icon:Icon(Icons.delete),onPressed:_del)]),
    body:FutureBuilder<Post>(future:_f,builder:(c,s){
      if(s.connectionState!=ConnectionState.done) return LoadingIndicator();
      if(s.hasError) return Center(child:Text('Error'));
      final p=s.data!;
      return Padding(padding:EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        if(p.image!=null)Image.network(p.image!),
        if(p.text!=null)Text(p.text!,style:TextStyle(fontSize:18)),
        if(p.address!=null)Text(p.address!),
        Text('Created: \${p.createdAt}'),
      ]));
    }),
  );
} 