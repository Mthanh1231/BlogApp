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
 @override _EditPostScreenState createState()=>_EditPostScreenState(); }
class _EditPostScreenState extends State<EditPostScreen> {
  final _form=GlobalKey<FormState>(); late String token,id; final _i=TextEditingController(),_t=TextEditingController(),_a=TextEditingController();
  bool _load=true;
  late UpdatePost ucUp;
  @override void didChangeDependencies(){ super.didChangeDependencies(); final args=ModalRoute.of(context)!.settings.arguments as Map;
    id=args['id']; token=args['token']; final api=ApiService(http.Client()); final repo=PostRepositoryImpl(api,token);
    ucUp=UpdatePost(repo);
    GetPostDetail(repo).execute(id).then((p){ _i.text=p.image??''; _t.text=p.text??''; _a.text=p.address??''; setState(()=>_load=false); });
  }
  @override void dispose(){_i.dispose();_t.dispose();_a.dispose();super.dispose();}
  Future _sub() async { if(!_form.currentState!.validate())return; setState(()=>_load=true);
    await ucUp.execute(id,{'image':_i.text,'text':_t.text,'address':_a.text}); Navigator.pop(context);
  }
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:Text('Edit Post')),
    body:_load?LoadingIndicator():Padding(padding:EdgeInsets.all(16),child:Form(
      key:_form,child:ListView(children:[
        TextFormField(controller:_i,decoration:InputDecoration(labelText:'Image URL')),
        TextFormField(controller:_t,decoration:InputDecoration(labelText:'Text'),validator:(v)=>v==null||v.isEmpty?'Required':null),
        TextFormField(controller:_a,decoration:InputDecoration(labelText:'Address')),
        SizedBox(height:20),ElevatedButton(onPressed:_sub,child:Text('Save'))
      ]),),),
  );
}