import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> memberJoinedGroupTripNotification({
    required String tripId,
    required String tripTitle,
    required String createdBy,
    required String joinedUserId,
  }) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(joinedUserId).get();
      final userData = userDoc.data();

      String joinedUserName = 'Someone'; // default fallback
      if (userData != null) {
        final firstName = userData['firstName'] ?? '';
        final lastName = userData['lastName'] ?? '';
        joinedUserName = '$firstName $lastName'.trim();
      }

      final timestamp = FieldValue.serverTimestamp();

      final notificationData = {
        'title': 'New User Joined Trip $tripTitle',
        'content': '$joinedUserName has joined your trip. Let\'s check it out',
        'timestamp': timestamp,
        // 'type': 'post',
        'tripId': tripId,
        'tripTitle': tripTitle,
        // 'userId': createdBy,
      };

      try {
        final notificationDocRef = _firestore
            .collection('users')
            .doc(createdBy)
            .collection('notifications')
            .doc();

        await notificationDocRef.set({
          'id': notificationDocRef.id,
          ...notificationData,
        });
      } catch (ex) {
        print('Failed to send notification to $createdBy: $ex');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> groupTripFullNotification({
    required String tripId,
    required String tripTitle,
    required String createdBy,
    required List<dynamic> members,
  }) async {
    try {
      final timestamp = FieldValue.serverTimestamp();

      final notificationData = {
        'title': 'Group Trip "$tripTitle" Full',
        'content':
            'Group trip "$tripTitle" is full. Let\'s check out who will be joining with you',
        'timestamp': timestamp,
        // 'type': 'experience',
        'tripId': tripId,
        'tripTitle': tripTitle,
      };

      for (String member in members) {
        try {
          final notificationDocRef = _firestore
              .collection('users')
              .doc(member)
              .collection('notifications')
              .doc();

          await notificationDocRef.set({
            'id': notificationDocRef.id,
            ...notificationData,
          });
        } catch (ex) {
          print('Failed to send notification to $member: $ex');
        }
      }
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id, // Include the notification ID here
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching notifications for user $userId: $e');
      return [];
    }
  }

  static Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      final notificationDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId);

      await notificationDocRef.delete();

      print('Notification $notificationId deleted for user $userId');
    } catch (e) {
      print('Error deleting notification $notificationId for user $userId: $e');
    }
  }
}
