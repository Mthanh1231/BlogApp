import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class EditHistoryScreen extends StatefulWidget {
  final String postId;
  final String token;

  const EditHistoryScreen({Key? key, required this.postId, required this.token})
    : super(key: key);

  @override
  _EditHistoryScreenState createState() => _EditHistoryScreenState();
}

class _EditHistoryScreenState extends State<EditHistoryScreen> {
  List<dynamic> history = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/posts/${widget.postId}/history?detail=true',
      );
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          history = data['history'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['message'] ?? 'Unknown error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit History')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : history.isEmpty
              ? Center(child: Text('No edit history'))
              : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, i) {
                  final item = history[i];
                  final diff = item['diff'] as Map<String, dynamic>;
                  return Card(
                    margin: EdgeInsets.all(12),
                    child: ListTile(
                      title: Text('Edited at: ${item['editedAt']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            diff.entries.map((e) {
                              return Text(
                                '${e.key}: "${e.value['from']}" → "${e.value['to']}"',
                                style: TextStyle(fontSize: 14),
                              );
                            }).toList(),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
