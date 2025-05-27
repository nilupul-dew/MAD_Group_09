import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/widgets/post_action_buttons.dart';
import 'package:hiking_app/presentation/widgets/post_options.dart';
import '../../../domain/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onDelete;
  final Future<void> Function()? onEdit;
  const PostTile({super.key, required this.post, this.onDelete, this.onEdit});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  int likeCount = 0;

  // Theme colors based on #E3641F
  static const Color primaryOrange = Color(0xFFE3641F);
  static const Color lightOrange = Color(0xFFFF8A50);
  static const Color darkOrange = Color(0xFFB8441A);
  static const Color orangeAccent = Color(0xFFFFF3EF);

  @override
  void initState() {
    super.initState();
    likeCount = (widget.post.id.hashCode % 50) + 1; // Simulate like count
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: primaryOrange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),

          // Content Section
          _buildContent(),

          // Image Section
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            _buildImageSection(),

          // Engagement Bar (Like count, etc.)
          _buildEngagementBar(),

          // Action Buttons
          buildActionButtons(context, widget.post),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryOrange, lightOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vasudeva Nanayakkara', // TODO: Replace with actual user name
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timeago.format(widget.post.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    if (widget.post.category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryOrange.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          widget.post.category,
                          style: const TextStyle(
                            color: darkOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Menu Button
          if (widget.post.userId == 'user123')
            // Replace with actual user ID check
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap:
                    () => PostOptionsWidget.showPostOptions(
                      context: context,
                      postId: widget.post.id,
                      onDelete: widget.onDelete,
                    ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Content
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF1C1C1E),
            ),
          ),
          Text(
            widget.post.tags.map((tag) => '#$tag').join(' '),
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color.fromARGB(255, 76, 76, 243),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        child: Stack(
          children: [
            Image.network(
              widget.post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[50],
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        primaryOrange,
                      ),
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (likeCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.thumb_up, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              '$likeCount',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
          const Spacer(),
          if (widget.post.tags.isNotEmpty) ...[
            Text(
              (likeCount - 10 < 0)
                  ? '0 Comments'
                  : '${likeCount - 10} Comments',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
