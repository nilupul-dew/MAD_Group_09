class Like {
  final String userId;

  Like({required this.userId});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(userId: json['userId']);
  }

  Map<String, dynamic> toJson() => {'userId': userId};
}
