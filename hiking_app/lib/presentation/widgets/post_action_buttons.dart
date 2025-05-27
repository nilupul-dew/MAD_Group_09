import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiking_app/data/firebase_services/FirebasePostInteractionService.dart';
import 'package:hiking_app/domain/models/post_model.dart';
import 'package:hiking_app/domain/models/share_model.dart';
import 'package:hiking_app/presentation/widgets/post_comment_sheet.dart';
import 'package:hiking_app/presentation/widgets/post_like_handlie.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

Widget buildActionButtons(BuildContext context, Post post) {
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
          child: LikeButtonWidget(
            postId: post.id,
            userId: 'user123', // TODO: Replace with actual logged-in user ID
          ),
        ),
        Container(width: 0.5, height: 24, color: Colors.grey.withOpacity(0.3)),
        Expanded(
          child: _PostActionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => CommentsBottomSheet(postId: post.id),
              );
            },
          ),
        ),
        Container(width: 0.5, height: 24, color: Colors.grey.withOpacity(0.3)),
        Expanded(
          child: _PostActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap:
                () => _showShareOptions(
                  context,
                  post.id,
                  'user123',
                ), // TODO: Replace 'user123' with actual logged-in user ID
          ),
        ),
      ],
    ),
  );
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    // ignore: unused_element_parameter
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
                color: isActive ? const Color(0xFFE3641F) : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFFE3641F) : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showShareOptions(BuildContext context, String postId, String userId) {
  final postService =
      FirebasePostInteractionService(); // Replace with your actual service instance

  void _logShare() async {
    final share = Share(userId: userId, timestamp: DateTime.now());
    await postService.sharePost(postId, share);
  }

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
                leading: const Icon(Icons.copy, color: Color(0xFFE3641F)),
                title: const Text('Copy Link'),
                onTap: () async {
                  final link =
                      'https://hikingapp.com/post/$postId'; // Replace with actual link format
                  await Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(context);
                  _logShare(); // Log share to Firestore
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFFE3641F)),
                title: const Text('Share via...'),
                onTap: () async {
                  final link =
                      'https://hikingapp.com/post/$postId'; // Replace as needed
                  await share_plus.Share.share(link);
                  Navigator.pop(context);
                  _logShare(); // Log share to Firestore
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
  );
}
