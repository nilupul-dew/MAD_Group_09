import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/post_firebase.dart';
import 'package:hiking_app/presentation/widgets/post_add.dart';
import '../widgets/post_tile.dart';
import '../../../domain/models/post_model.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseForumService _service = FirebaseForumService();

  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _service.fetchPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading posts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Forum")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _posts.isEmpty
              ? const Center(child: Text("No posts yet. Add the first post!"))
              : RefreshIndicator(
                onRefresh: () async => _loadPosts(),
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder:
                      (_, i) => PostTile(
                        post: _posts[i],
                        onDelete: _loadPosts,
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddPostScreen(
                                    isEditing: true,
                                    post: _posts[i],
                                  ),
                            ),
                          );
                          if (result == true) {
                            _loadPosts(); // Refresh after edit
                          }
                        },
                      ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          ).then((result) {
            if (result == true) {
              _loadPosts(); // Refresh after adding
            }
          });
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
