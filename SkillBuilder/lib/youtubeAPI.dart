import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YtAPI {
  final YouTubeApi _youtube;
  YtAPI() : _youtube = YouTubeApi(clientViaApiKey('YOUR GOOGLE API KEY HERE')); // <-- INSERT KEY


  Future<List<SearchResult>?> search(String query) async {
    final searchListResponse = await _youtube.search.list(
      ['snippet'], // include only 'snippet' to get basic video details, or do ['snippet', 'video'], to get both
      q: query,
      type: ['video'],
      maxResults: 5,
    );

    return searchListResponse.items;
  }

}

/** Helper Class for Results Display */
class SearchResultsWidget extends StatefulWidget {
  final YtAPI ytApi;
  final String searchTerm;

  SearchResultsWidget({required this.ytApi, required this.searchTerm});

  @override
  _SearchResultsWidgetState createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  late Future<List<SearchResult>?> _searchResultsFuture;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = widget.ytApi.search(widget.searchTerm);
  }

  void _launchVideoUrl(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void didUpdateWidget(SearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != oldWidget.searchTerm) {
      setState(() {
        _searchResultsFuture = widget.ytApi.search(widget.searchTerm);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searchTerm.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Videos related to "${widget.searchTerm}"',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Courier New', fontSize: 18.0),
            ),
          ),
        Expanded(
          child: FutureBuilder<List<SearchResult>?>(
            future: _searchResultsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final searchResults = snapshot.data!.take(3).toList();
                  return ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final searchResult = searchResults[index];
                      final thumbnailUrl = searchResult.snippet!.thumbnails!.medium!.url;
                      final title = searchResult.snippet!.title;
                      final videoId = searchResult.id!.videoId;

                      return GestureDetector(
                        onTap: () => _launchVideoUrl(videoId!),
                        child: ListTile(
                          leading: Image.network(thumbnailUrl!),
                          title: Text(title!, style: TextStyle(color: Colors.white, fontFamily: 'Courier New', fontSize: 16.0)),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No video results found.', style: TextStyle(color: Colors.white, fontFamily: 'Courier New')));
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }

}
