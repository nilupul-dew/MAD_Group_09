import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/Post/post_model.dart';
import 'package:hiking_app/data/firebase_services/Post/post_firebase.dart';
import 'post_tile.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;

class PostSearchScreen extends StatefulWidget {
  const PostSearchScreen({super.key});

  @override
  State<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseForumService _service = FirebaseForumService();
  List<Post> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _suggestions = [];
  List<String> _allTags = [];

  // //voice input
  // late stt.SpeechToText _speech;
  // bool _isListening = false;
  // String _voiceInput = "";

  @override
  void initState() {
    super.initState();
    //_speech = stt.SpeechToText();
    _loadRecentSearches();
    _loadAllTags();
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _loadAllTags() async {
    final posts = await _service.fetchPosts();
    final tagSet = <String>{};
    for (var post in posts) {
      tagSet.addAll(post.tags);
    }
    setState(() {
      _allTags = tagSet.toList();
    });
  }

  Future<void> _saveSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _searchPosts(String query) async {
    print("🔍 Searching for: $query");
    query = query.trim().toLowerCase();
    if (query.isEmpty) return;

    await _saveSearch(query);
    final results = await _service.fetchPosts();

    final queryWords = query.split(' ');

    setState(() {
      _searchResults = results.where((post) {
        final lowerTags = post.tags.map((tag) => tag.toLowerCase()).toList();
        return queryWords.any(
          (word) => lowerTags.any((tag) => tag.contains(word)),
        );
      }).toList();
      _suggestions.clear();
    });

    print("✅ Found \${_searchResults.length} matching posts.");
  }

  void _updateSuggestions(String input) {
    final normalized = input.trim().toLowerCase();
    setState(() {
      _suggestions = _allTags
          .where((tag) => tag.toLowerCase().contains(normalized))
          .toList();
    });
  }

  void _removeSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(query);
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _clearAllRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.clear();
    });
    await prefs.remove('recent_searches');
  }

  // //Voice to text functionality
  // void _startListening() async {
  //   bool available = await _speech.initialize(
  //     onStatus: (val) => print('🔊 STATUS: $val'),
  //     onError: (val) => print('❌ ERROR: $val'),
  //   );
  //   if (available) {
  //     print('🎤 Voice input initialized');
  //     setState(() => _isListening = true);
  //     _speech.listen(
  //       onResult: (val) {
  //         print('🎤 onResult triggered');
  //         setState(() {
  //           _voiceInput = val.recognizedWords;
  //           _searchController.text = _voiceInput;
  //         });
  //         print('🎤 Recognized words: $_voiceInput');
  //         if (val.hasConfidenceRating && val.confidence > 0) {
  //           _searchPosts(_voiceInput);
  //         }
  //       },
  //     );
  //     // Automatically stop after 10 seconds
  //     Timer(const Duration(seconds: 10), () {
  //       _stopListening();
  //     });
  //   }
  // }

  // void _stopListening() {
  //   _speech.stop();
  //   setState(() => _isListening = false);
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search posts...',
                  border: InputBorder.none,
                ),
                onChanged: _updateSuggestions,
                onSubmitted: _searchPosts,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _searchPosts(_searchController.text);
              },
            ),
            // IconButton(
            //   icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            //   onPressed: _isListening ? _stopListening : _startListening,
            // ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: _suggestions
                    .map(
                      (s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          _searchController.text = s;
                          _searchPosts(s);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) =>
                        PostTile(post: _searchResults[index]),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _clearAllRecentSearches,
                              child: const Text("Clear All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _recentSearches
                              .map(
                                (query) => InputChip(
                                  label: Text(query),
                                  onPressed: () {
                                    _searchController.text = query;
                                    _searchPosts(query);
                                  },
                                  onDeleted: () => _removeSearch(query),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
