import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/post_firebase.dart';
import 'package:hiking_app/presentation/widgets/post_add.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/post_tile.dart';
import '../../../domain/models/post_model.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseForumService _service = FirebaseForumService();
  final ImagePicker _picker = ImagePicker();

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
              : ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (_, i) => PostTile(post: _posts[i]),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          ).then((_) => _loadPosts());
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
