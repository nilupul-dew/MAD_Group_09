import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/domain/models/comment_model.dart';
import 'package:hiking_app/domain/models/share_model.dart';

class FirebasePostInteractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Comment
  Future<void> addComment(String postId, Comment comment) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toJson());
  }

  // Get Comments
  Future<List<Comment>> getComments(String postId) async {
    final snapshot =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data(), doc.id))
        .toList();
  }

  //get comments count
  Stream<int> getCommentsCount(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete Comment
  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // Like Post
  Future<void> likePost(String postId, String userId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .set({'userId': userId});
  }

  // Unlike Post
  Future<void> unlikePost(String postId, String userId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .delete();
  }

  // Check if user liked the post
  Future<bool> isPostLiked(String postId, String userId) async {
    final doc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();

    return doc.exists;
  }

  // Get total likes count
  Stream<int> getLikesCount(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Share Post
  Future<void> sharePost(String postId, Share share) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('shares')
        .doc(share.userId)
        .set(share.toJson());
  }

  // Get shares count
  Stream<int> getSharesCount(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('shares')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
