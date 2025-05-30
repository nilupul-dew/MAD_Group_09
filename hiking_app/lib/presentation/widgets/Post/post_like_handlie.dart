import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeDocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final docSnapshot = await likeDocRef.get();

    if (docSnapshot.exists) {
      // Unlike
      await likeDocRef.delete();
    } else {
      // Like
      await likeDocRef.set({'userId': userId, 'timestamp': Timestamp.now()});
    }
  }

  Future<bool> isPostLikedByUser({
    required String postId,
    required String userId,
  }) async {
    final likeDoc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();
    return likeDoc.exists;
  }

  Stream<int> getLikeCountStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

class LikeButtonWidget extends StatefulWidget {
  final String postId;
  final String userId;
  const LikeButtonWidget({
    super.key,
    required this.postId,
    required this.userId,
  });

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isLiked = false;
  int likeCount = 0;
  final _likeService = LikeService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _initLikeStatus();
  }

  Future<void> _initLikeStatus() async {
    final liked = await _likeService.isPostLikedByUser(
      postId: widget.postId,
      userId: widget.userId,
    );
    setState(() {
      isLiked = liked;
    });
  }

  void _handleLike() async {
    await _likeService.toggleLike(postId: widget.postId, userId: widget.userId);

    setState(() {
      isLiked = !isLiked;
    });

    if (isLiked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLike,
      child: ScaleTransition(
        scale: _animationController.drive(
          Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: isLiked ? const Color(0xFFE3641F) : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Like',
                style: TextStyle(
                  fontSize: 14,
                  color: isLiked ? const Color(0xFFE3641F) : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
