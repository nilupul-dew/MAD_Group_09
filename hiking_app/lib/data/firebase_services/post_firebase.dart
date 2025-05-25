import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  // Web-compatible image upload

  Future<String?> saveImageLocally(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);
      print("✅ Image saved locally: $imagePath");
      return imagePath;
    } catch (e) {
      print("❌ Error saving image locally: $e");
      return null;
    }
  }

  Future<Uint8List?> compressImage(Uint8List originalBytes) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        quality: 60, // Adjust from 0 (max compression) to 100 (no compression)
        minWidth: 800, // Optional: reduce image dimensions
        minHeight: 800,
      );
      print(
        "📉 Compressed from ${originalBytes.lengthInBytes} to ${compressedBytes.lengthInBytes} bytes",
      );
      return compressedBytes;
    } catch (e) {
      print("❌ Compression failed: $e");
      return originalBytes; // fallback to original if compression fails
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
      String? imagePath;

      // Save image locally if provided
      if (imageBytes != null && imageName != null) {
        try {
          Uint8List? processedBytes = imageBytes;
          if (!kIsWeb) {
            processedBytes = await compressImage(imageBytes);
          }
          imagePath = await saveImageLocally(processedBytes!, imageName);
          if (imagePath == null) {
            print("❌ Image save failed, aborting post creation.");
            return;
          }
        } catch (e) {
          print("❌ Error saving image: $e");
          return;
        }
      }

      final docRef = await _firestore.collection(_collection).add({
        'userId': post.userId,
        'title': post.title,
        'content': post.content,
        'category': post.category,
        'tags': post.tags,
        'imageUrl': imagePath,
        'timestamp': Timestamp.fromDate(post.timestamp),
      });
      print("✅ Post added with ID: ${docRef.id}");
    } catch (e) {
      print("❌ Error adding post: $e");
      throw e;
    }
  }
}
