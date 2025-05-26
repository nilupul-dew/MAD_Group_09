import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  // OPTION 1: ImgBB (Free tier: unlimited uploads, 32MB per image)
  Future<String?> uploadToImgBB(Uint8List imageBytes, String fileName) async {
    try {
      const apiKey = '7a6786581dabb83cf3d9fef912b12b8f';

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
        return null;
      }
    } catch (e) {
      print("❌ Error uploading to ImgBB: $e");
      return null;
    }
  }

  Future<Uint8List?> compressImage(Uint8List originalBytes) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );
      print(
        "📉 Compressed from ${originalBytes.lengthInBytes} to ${compressedBytes.lengthInBytes} bytes",
      );
      return compressedBytes;
    } catch (e) {
      print("❌ Compression failed: $e");
      return originalBytes;
    }
  }

  Future<List<Post>> fetchPosts() async {
    print("🔍 Starting to fetch posts from collection: $_collection");
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .orderBy('timestamp', descending: true)
              .get();

      print("📊 Found ${querySnapshot.docs.length} documents");

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No documents found in posts collection");
        return [];
      }

      final posts =
          querySnapshot.docs.map((doc) {
            print("📄 Processing document: ${doc.id}");
            final data = doc.data();
            print("📝 Document data: $data");

            return Post(
              id: doc.id,
              userId: data['userId'] ?? '',
              title: data['title'] ?? '',
              content: data['content'] ?? '',
              category: data['category'] ?? '',
              tags: List<String>.from(data['tags'] ?? []),
              imageUrl: data['imageUrl'],
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

      print("✅ Successfully converted ${posts.length} posts");
      return posts;
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }

  Future<void> addPost(
    Post post, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    print("📝 Adding post: ${post.title}");
    try {
      String? imageUrl;

      if (imageBytes != null && imageName != null) {
        try {
          // Generate unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final uniqueFileName = '${timestamp}_$imageName';

          // Try different services in order of preference
          imageUrl = await uploadToImgBB(imageBytes, uniqueFileName);

          if (imageUrl == null) {
            print(
              "❌ All image upload services failed, aborting post creation.",
            );
            return;
          }
        } catch (e) {
          print("❌ Error processing image: $e");
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

      print("✅ Image URL stored in DB: $imageUrl");
      print("✅ Post added with ID: ${docRef.id}");
    } catch (e) {
      print("❌ Error adding post: $e");
      throw e;
    }
  }
}
