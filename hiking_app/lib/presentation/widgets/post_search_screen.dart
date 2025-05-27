import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/post_model.dart';
import 'package:hiking_app/data/firebase_services/post_firebase.dart';
import 'post_tile.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
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

    final queryWords = query.split(' '); // e.g., ["chariot", "path"]

    setState(() {
      _searchResults =
          results.where((post) {
            final lowerTags =
                post.tags.map((tag) => tag.toLowerCase()).toList();
            // Match if any query word is found in any tag
            return queryWords.any(
              (word) => lowerTags.any((tag) => tag.contains(word)),
            );
          }).toList();
    });

    print("✅ Found ${_searchResults.length} matching posts.");
  }

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
                textInputAction:
                    TextInputAction.search, // 🔍 Makes keyboard show 'Search'
                decoration: const InputDecoration(
                  hintText: 'Search posts...',
                  border: InputBorder.none,
                ),
                onSubmitted: _searchPosts, // ✅ triggers on 'Enter'
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _searchPosts(_searchController.text); // ✅ triggers on icon tap
              },
            ),
          ],
        ),
      ),

      body:
          _searchResults.isNotEmpty
              ? ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder:
                    (context, index) => PostTile(post: _searchResults[index]),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          _recentSearches
                              .map(
                                (query) => ActionChip(
                                  label: Text(query),
                                  onPressed: () {
                                    _searchController.text = query;
                                    _searchPosts(query);
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
    );
  }
}
