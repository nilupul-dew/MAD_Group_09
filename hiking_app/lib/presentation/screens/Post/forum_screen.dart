import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hiking_app/data/firebase_services/Post/post_firebase.dart';
import 'package:hiking_app/data/firebase_services/user/auth_service.dart';
import 'package:hiking_app/presentation/screens/app_bar.dart';
import 'package:hiking_app/presentation/screens/group_trip_screen.dart';
import 'package:hiking_app/presentation/screens/user/user_profile_screen.dart';
import 'package:hiking_app/presentation/widgets/Post/post_add.dart';
import 'package:hiking_app/presentation/widgets/Post/post_search_screen.dart';
import '../../widgets/Post/post_tile.dart';
import '../../../domain/models/Post/post_model.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseForumService _service = FirebaseForumService();

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _showFAB = true;
  final ScrollController _scrollController = ScrollController();
  String? _profileImageUrl;

  // Initialize the scroll controller and load posts
  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadUserImage();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse && _showFAB) {
        setState(() => _showFAB = false);
      } else if (direction == ScrollDirection.forward && !_showFAB) {
        setState(() => _showFAB = true);
      }
    });
  }

  Future<void> _loadUserImage() async {
    final userData = await AuthService.getUserData();
    if (userData != null) {
      setState(() {
        _profileImageUrl = userData['profileImage'] ?? userData['photoURL'];
      });
    }
    print("🔍 User profile image URL: $_profileImageUrl");
  }

  // Load posts from Firebase
  void _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await _service.fetchPosts();

      // Sort posts by descending timestamp
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading posts: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        color: const Color.fromARGB(
            255, 211, 209, 209), // Set your desired background color here
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? const Center(child: Text("No posts yet. Add the first post!"))
                : RefreshIndicator(
                    onRefresh: () async => _loadPosts(),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          snap: true,
                          backgroundColor: Colors.white,
                          elevation: 1,
                          automaticallyImplyLeading: false,
                          titleSpacing: 16,
                          title: Row(
                            children: [
                              // 👤 User Avatar
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserProfileScreen()),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _profileImageUrl != null &&
                                          _profileImageUrl!.isNotEmpty
                                      ? NetworkImage(_profileImageUrl!)
                                      : null,
                                  child: _profileImageUrl == null ||
                                          _profileImageUrl!.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.grey)
                                      : null,
                                ),
                              ),

                              const SizedBox(width: 12),

                              // 🔍 Search field (non-interactive placeholder)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Open Search Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PostSearchScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      "Where's your next adventure?",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // ➕ Add Post Button
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFF5F5F5),
                                child: IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.black),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddPostScreen(),
                                      ),
                                    );
                                    if (result == true) _loadPosts();
                                  },
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 👥 Group Trip Button (for future)
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFF5F5F5),
                                child: IconButton(
                                  icon: const Icon(Icons.group,
                                      color: Colors.black),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupTripScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => PostTile(
                              post: _posts[i],
                              onDelete: _loadPosts,
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPostScreen(
                                      isEditing: true,
                                      post: _posts[i],
                                    ),
                                  ),
                                );
                                if (result == true) _loadPosts();
                              },
                            ),
                            childCount: _posts.length,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
