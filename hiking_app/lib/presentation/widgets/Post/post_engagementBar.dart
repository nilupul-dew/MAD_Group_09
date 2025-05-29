import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/Post/FirebasePostInteractionService.dart';

Widget buildEngagementBar(BuildContext context, String postId) {
  final service = FirebasePostInteractionService();

  return StreamBuilder<int>(
    stream: service.getLikesCount(postId),
    builder: (context, likeSnapshot) {
      return StreamBuilder<int>(
        stream: service.getCommentsCount(postId),
        builder: (context, commentSnapshot) {
          return StreamBuilder<int>(
            stream: service.getSharesCount(postId),
            builder: (context, shareSnapshot) {
              final likeCount = likeSnapshot.data ?? 0;
              final commentCount = commentSnapshot.data ?? 0;
              final shareCount = shareSnapshot.data ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (likeCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3641F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.thumb_up,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$likeCount',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                    const Spacer(),
                    if (commentCount > 0)
                      Text(
                        '$commentCount Comment${commentCount > 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    if (commentCount > 0 && shareCount > 0)
                      const SizedBox(width: 12),
                    if (shareCount > 0)
                      Text(
                        '$shareCount Share${shareCount > 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
