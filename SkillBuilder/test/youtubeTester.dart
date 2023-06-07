import 'dart:async';
import 'package:flutter/material.dart';
import 'youtubeAPI.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenAIScreen extends StatefulWidget {
  @override
  _OpenAIScreenState createState() => _OpenAIScreenState();
}

class _OpenAIScreenState extends State<OpenAIScreen> {
  final YtAPI ytApi = YtAPI();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Search Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('YouTube Search Demo'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search term',
              ),
              onChanged: (value) {
                setState(() {}); // trigger rebuild
              },
            ),
            Expanded(
              child: SearchResultsWidget(
                ytApi: ytApi,
                searchTerm: _controller.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
