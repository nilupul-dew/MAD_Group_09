import 'package:cloud_firestore/cloud_firestore.dart';

class Share {
  final String userId;
  final DateTime timestamp;

  Share({required this.userId, required this.timestamp});

  factory Share.fromJson(Map<String, dynamic> json) {
    return Share(
      userId: json['userId'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {'userId': userId, 'timestamp': timestamp};
}
