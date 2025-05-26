import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/post_firebase.dart';
import 'package:hiking_app/presentation/widgets/post_add.dart';

// Define the primary orange color - update this to match your app's color
const Color primaryOrange = Color(0xFFFF6B35);

class PostOptionsWidget {
  static void showPostOptions({
    required BuildContext context,
    required String postId,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final rootContext = context;
    showModalBottomSheet(
      context: rootContext,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext sheetContext) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Edit option
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: primaryOrange,
                  ),
                  title: const Text('Edit Post'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet

                    try {
                      final post = await FirebaseForumService().fetchPostById(
                        postId,
                      );

                      if (post != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddPostScreen(isEditing: true, post: post),
                          ),
                        );
                      } else {
                        print('⚠️ Post not found for ID: $postId');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post not found')),
                        );
                      }
                    } catch (e) {
                      print('❌ Error loading post for editing: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to load post for editing'),
                        ),
                      );
                    }
                  },
                ),

                // Delete option with confirmation
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Future.delayed(Duration(milliseconds: 100), () {
                      _showDeleteConfirmation(
                        // ignore: use_build_context_synchronously
                        context: rootContext,
                        postId: postId,
                        onConfirm: onDelete,
                      );
                    });
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  // Alternative method with confirmation dialog for delete
  static void showPostOptionsWithConfirmation({
    required BuildContext context,
    required String postId,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Edit option
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: primaryOrange,
                  ),
                  title: const Text('Edit Post'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet

                    try {
                      final post = await FirebaseForumService().fetchPostById(
                        postId,
                      );

                      if (post != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddPostScreen(isEditing: true, post: post),
                          ),
                        );
                      } else {
                        print('⚠️ Post not found for ID: $postId');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post not found')),
                        );
                      }
                    } catch (e) {
                      print('❌ Error loading post for editing: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to load post for editing'),
                        ),
                      );
                    }
                  },
                ),

                // Delete option with confirmation
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Future.delayed(Duration.zero, () {
                      _showDeleteConfirmation(
                        context: context,
                        postId: postId,
                        onConfirm: onDelete,
                      );
                    });
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  // Private method for delete confirmation
  static void _showDeleteConfirmation({
    required BuildContext context,
    required String postId,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await FirebaseForumService().deletePost(postId);
                    if (onConfirm != null) onConfirm(); // <-- reload posts here
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete post: $e')),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
