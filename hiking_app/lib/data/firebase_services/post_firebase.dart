import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../domain/models/post_model.dart';

class FirebaseForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  // 🔵 Upload image to ImgBB
  Future<String?> uploadToImgBB(Uint8List imageBytes, String fileName) async {
    const apiKey = '7a6786581dabb83cf3d9fef912b12b8f';

    try {
      final base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {'key': apiKey, 'image': base64Image, 'name': fileName},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data']['url'];
        print("✅ Image uploaded to ImgBB: $imageUrl");
        return imageUrl;
      } else {
        print("❌ ImgBB upload failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error uploading to ImgBB: $e");
    }
    return null;
  }

  // 🟣 Compress image to reduce size
  Future<Uint8List?> compressImage(Uint8List originalBytes) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        originalBytes,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );
      print(
        "📉 Compressed from ${originalBytes.lengthInBytes} → ${compressed.lengthInBytes} bytes",
      );
      return compressed;
    } catch (e) {
      print("❌ Compression failed: $e");
      return originalBytes;
    }
  }

  // 🟡 Fetch all posts (ordered by timestamp)
  Future<List<Post>> fetchPosts() async {
    print("🔄 Fetching posts from Firestore...");
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('timestamp', descending: true)
              .get();

      final posts =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Post(
              id: doc.id,
              userId: data['userId'] ?? '',
              title: data['title'] ?? '',
              content: data['content'] ?? '',
              category: data['category'] ?? '',
              tags: List<String>.from(data['tags'] ?? []),
              imageUrl: data['imageUrl'],
              timestamp:
                  data['timestamp'] is Timestamp
                      ? (data['timestamp'] as Timestamp).toDate()
                      : DateTime.tryParse(data['timestamp'] ?? '') ??
                          DateTime.now(),
            );
          }).toList();

      print("✅ Loaded ${posts.length} posts from Firestore.");
      return posts;
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }

  // 🟢 Add a new post
  Future<void> addPost(
    Post post, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      String? imageUrl;

      if (imageBytes != null && imageName != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$imageName';
        imageUrl = await uploadToImgBB(imageBytes, uniqueFileName);

        if (imageUrl == null) {
          print("❌ Image upload failed. Post creation aborted.");
          return;
        }
      }

      final docRef = await _firestore.collection(_collection).add({
        'userId': post.userId,
        'title': post.title,
        'content': post.content,
        'category': post.category,
        'tags': post.tags,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(post.timestamp),
      });

      print("✅ Post added with ID: ${docRef.id}");
    } catch (e) {
      print("❌ Error adding post: $e");
      rethrow;
    }
  }

  // 🔴 Delete post by ID
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).delete();
      print('✅ Post "$postId" deleted successfully.');
    } catch (e) {
      print('❌ Error deleting post "$postId": $e');
      rethrow;
    }
  }

  // 🔵 Fetch post by ID (for edit)
  Future<Post?> fetchPostById(String postId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Post(
            id: doc.id,
            userId: data['userId'] ?? '',
            title: data['title'] ?? '',
            content: data['content'] ?? '',
            category: data['category'] ?? '',
            tags: List<String>.from(data['tags'] ?? []),
            imageUrl: data['imageUrl'],
            timestamp:
                data['timestamp'] is Timestamp
                    ? (data['timestamp'] as Timestamp).toDate()
                    : DateTime.tryParse(data['timestamp'] ?? '') ??
                        DateTime.now(),
          );
        }
      }
    } catch (e) {
      print('❌ Error fetching post by ID "$postId": $e');
    }
    return null;
  }

  Future<void> updatePost(
    Post post, {
    Uint8List? imageBytes,
    String? imageName,
    String? updatedContent,
    String? updatedCategory,
    List<String>? updatedTags,
  }) async {
    try {
      String? finalImageUrl = post.imageUrl;

      // Upload new image if provided
      if (imageBytes != null && imageName != null) {
        final uploadedUrl = await uploadToImgBB(imageBytes, imageName);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          finalImageUrl = uploadedUrl;
        } else {
          print(
            "⚠️ Image upload failed or returned null. Keeping existing image.",
          );
        }
      }

      // Build the updated Post object
      final updatedPost = post.copyWith(
        content: updatedContent ?? post.content,
        category: updatedCategory ?? post.category,
        tags: updatedTags ?? post.tags,
        imageUrl: finalImageUrl, // Use final determined image URL
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .update(updatedPost.toJson());

      print("✅ Post updated: ${post.id}");
    } catch (e) {
      print("❌ Error updating post: $e");
      rethrow;
    }
  }
}
