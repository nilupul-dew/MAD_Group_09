import 'package:flutter/material.dart';
import '../../../domain/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatefulWidget {
  final Post post;

  const PostTile({super.key, required this.post});

  // Generate dummy user names based on post ID for consistency
  String _getDummyUserName() {
    final names = [
      'Alex Thompson',
      'Sarah Johnson',
      'Mike Chen',
      'Emma Davis',
      'Jake Wilson',
      'Lisa Rodriguez',
      'Ryan Martinez',
      'Maya Patel',
      'Chris Anderson',
      'Nina Garcia',
      'Tom Bradley',
      'Amy Foster',
      'David Kim',
      'Zoe Miller',
      'Leo Turner',
    ];

    // Use post ID hash to consistently assign same name to same post
    final index = post.userId.hashCode.abs() % names.length;
    return names[index];
  }

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  int likeCount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Theme colors based on #E3641F
  static const Color primaryOrange = Color(0xFFE3641F);
  static const Color lightOrange = Color(0xFFFF8A50);
  static const Color darkOrange = Color(0xFFB8441A);
  static const Color orangeAccent = Color(0xFFFFF3EF);
  static const Color mutedOrange = Color(0xFFE3641F);

  @override
  void initState() {
    super.initState();
    likeCount = (widget.post.id.hashCode % 50) + 1; // Simulate like count

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
      isLiked = !isLiked;
    });
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
          _buildActionButtons(),
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
                  widget._getDummyUserName(),
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showPostOptions(context),
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
          // Post Title
          if (widget.post.title.isNotEmpty) ...[
            Text(
              widget.post.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Post Content
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF1C1C1E),
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
              '${widget.post.tags.length} tags',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PostActionButton(
              icon: isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              label: 'Like',
              isActive: isLiked,
              onTap: _handleLike,
              scaleAnimation: _scaleAnimation,
            ),
          ),
          Container(
            width: 0.5,
            height: 24,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _PostActionButton(
              icon: Icons.comment_outlined,
              label: 'Comment',
              onTap: () {
                print('Comment on post: ${widget.post.id}');
                _showCommentsBottomSheet(context);
              },
            ),
          ),
          Container(
            width: 0.5,
            height: 24,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _PostActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () {
                print('Shared post: ${widget.post.id}');
                _showShareOptions(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
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
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: primaryOrange,
                  ),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    print('Edit post: ${widget.post.id}');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete Post'),
                  onTap: () {
                    Navigator.pop(context);
                    print('Delete post: ${widget.post.id}');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: const [
                            Text('Comments will be implemented here...'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showShareOptions(BuildContext context) {
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
                    'Share Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.copy, color: primaryOrange),
                  title: const Text('Copy Link'),
                  onTap: () {
                    Navigator.pop(context);
                    print('Copy link');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: primaryOrange),
                  title: const Text('Share via...'),
                  onTap: () {
                    Navigator.pop(context);
                    print('Share via system share');
                  },
                ),
                const SizedBox(height: 8),
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
  final bool isActive;
  final Animation<double>? scaleAnimation;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Color(0xFFE3641F) : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Color(0xFFE3641F) : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (scaleAnimation != null && isActive) {
      return AnimatedBuilder(
        animation: scaleAnimation!,
        builder:
            (context, child) =>
                Transform.scale(scale: scaleAnimation!.value, child: button),
      );
    }

    return button;
  }
}
