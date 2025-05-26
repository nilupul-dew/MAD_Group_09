import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String? imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    this.imageUrl,
    required this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json, String id) {
    final timestampData = json['timestamp'];
    DateTime timestamp;

    if (timestampData is Timestamp) {
      timestamp = timestampData.toDate(); // Firestore Timestamp
    } else if (timestampData is String) {
      timestamp = DateTime.parse(timestampData); // ISO 8601 string
    } else {
      throw FormatException("Invalid timestamp format");
    }

    return Post(
      id: id,
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'title': title,
    'content': content,
    'category': category,
    'tags': tags,
    'imageUrl': imageUrl,
    'timestamp': timestamp.toIso8601String(),
  };

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
