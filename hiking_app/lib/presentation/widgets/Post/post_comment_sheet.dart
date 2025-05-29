import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/Post/FirebasePostInteractionService.dart';
import 'package:hiking_app/domain/models/Post/comment_model.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final FirebasePostInteractionService _service =
      FirebasePostInteractionService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await _service.getComments(widget.postId);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final comment = Comment(
      id: UniqueKey().toString(), // Generate a unique id or use your logic
      userId: 'user123', // Replace with actual user ID
      content: text, // Use 'content' instead of 'text'
      timestamp: DateTime.now(),
    );

    await _service.addComment(widget.postId, comment);
    _commentController.clear();
    _loadComments();
  }

  Future<void> _deleteComment(String commentId) async {
    await FirebasePostInteractionService().deleteComment(
      widget.postId,
      commentId,
    );
    _loadComments();
  }

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            controller: scrollController,
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      backgroundColor: const Color.fromRGBO(
                                        227,
                                        100,
                                        31,
                                        1,
                                      ),
                                      radius: 16,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ), // slightly smaller avatar
                                    ),
                                    const SizedBox(width: 12),

                                    // Comment content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Username
                                          const Text(
                                            'Mahinda Rajapaksha', // Replace with actual username
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),

                                          // Comment text
                                          Text(
                                            comment.content,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          // Like, Reply, Timestamp
                                          Row(
                                            children: [
                                              const Text(
                                                'Like',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                'Reply',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                timeAgo(
                                                  comment.timestamp,
                                                ), // Use a helper function for formatting
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Delete button
                                    comment.userId ==
                                            'user123' // Replace with actual user ID check
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20, // smaller delete icon
                                          ),
                                          onPressed:
                                              () => _deleteComment(comment.id),
                                        )
                                        : const SizedBox.shrink(), // placeholder when no icon shown
                                  ],
                                ),
                              );
                            },
                          ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
