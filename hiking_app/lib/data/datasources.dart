import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/group_trip_model.dart';

class TripDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create new trip
  Future<void> createTrip(Trip trip) async {
    try {
      await _firestore.collection('trips').doc(trip.tripid).set(trip.toMap());
    } catch (e) {
      print('Error creating trip: $e');
      rethrow;
    }
  }

  // Get all active trips
  Stream<List<Trip>> getActiveTrips() {
    return _firestore
        .collection('trips')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Trip.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Join a trip
  Future<void> joinTrip(String tripId) async {
    final userId = _auth.currentUser!.uid;
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error joining trip: $e');
      rethrow;
    }
  }

  // Check if user joined a trip
  Future<bool> checkMembership(String tripId) async {
    final userId = _auth.currentUser!.uid;
    final doc = await _firestore.collection('trips').doc(tripId).get();
    final members = List<String>.from(doc.data()?['members'] ?? []);
    return members.contains(userId);
  }
}
