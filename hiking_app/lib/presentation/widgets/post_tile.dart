import 'package:flutter/material.dart';
import '../../../domain/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header: Post title and menu ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // TODO: Handle edit/delete actions
                    print("Selected: $value");
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),

            SizedBox(height: 4),

            /// --- Timestamp ---
            Text(
              timeago.format(post.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),

            SizedBox(height: 10),

            /// --- Content ---
            Text(post.content),

            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text("⚠️ Failed to load image"),
                ),
              ),
            ],

            SizedBox(height: 10),

            /// --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostActionButton(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Like',
                  onTap: () {
                    print('Liked post: ${post.id}');
                  },
                ),
                _PostActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () {
                    print('Comment on post: ${post.id}');
                  },
                ),
                _PostActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    print('Shared post: ${post.id}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [Icon(icon, size: 20), SizedBox(width: 4), Text(label)],
      ),
    );
  }
}
