import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/post_firebase.dart';
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

  void _showAddPostDialog() {
    String title = '';
    String content = '';
    String category = 'Tips';
    Uint8List? selectedImageBytes;
    String? selectedImageName;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('New Post'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (val) => title = val,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          onChanged: (val) => content = val,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),

                        /// Image selection button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              final bytes = await pickedFile.readAsBytes();
                              final compressedBytes = await _service
                                  .compressImage(bytes);
                              if (compressedBytes != null) {
                                setDialogState(() {
                                  selectedImageBytes = compressedBytes;
                                  selectedImageName = pickedFile.name;
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: Text(
                            selectedImageBytes != null
                                ? 'Image Selected'
                                : 'Add Image',
                          ),
                        ),
                        if (selectedImageBytes != null)
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (title.isEmpty || content.isEmpty) {
                          print("⚠️ Title or content is empty");
                          return;
                        }

                        final post = Post(
                          id: '',
                          userId: 'user123',
                          title: title,
                          content: content,
                          category: category,
                          tags: ['example', 'demo'],
                          imageUrl: null,
                          timestamp: DateTime.now(),
                        );

                        try {
                          await _service.addPost(
                            post,
                            imageBytes: selectedImageBytes,
                            imageName: selectedImageName,
                          );
                          Navigator.pop(context);
                          _loadPosts();
                        } catch (e) {
                          print("❌ Error adding post: $e");
                        }
                      },
                      child: const Text('Post'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
          ),
    );
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
        onPressed: _showAddPostDialog,
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
