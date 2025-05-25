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
    return Post(
      id: id,
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
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
}
