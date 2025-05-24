class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<String> images;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.images = const [],
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
    List<String>? images,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      images: images ?? this.images,
    );
  }
}
