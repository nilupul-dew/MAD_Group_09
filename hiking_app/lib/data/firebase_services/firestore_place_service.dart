// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hiking_app/domain/models/place_model.dart';

// class FirestorePlaceService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<PlaceModel>> getAllPlaces() async {
//     final snapshot = await _firestore.collection('places').get();
//     return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
//   }

//   Future<List<PlaceModel>> searchPlaces(String query) async {
//     final snapshot =
//         await _firestore
//             .collection('places')
//             .where('name', isGreaterThanOrEqualTo: query)
//             .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//             .get();

//     return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
//   }

//   Future<List<PlaceModel>> filterPlacesByCategory(String category) async {
//     final snapshot =
//         await _firestore
//             .collection('places')
//             .where('category', isEqualTo: category)
//             .get();

//     return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/domain/models/place_model.dart';

class FirestorePlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PlaceModel>> getAllPlaces() async {
    final snapshot = await _firestore.collection('places').get();
    return snapshot.docs
        .map((doc) => PlaceModel.fromJson(_convertFirestoreDoc(doc)))
        .toList();
  }

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final snapshot =
        await _firestore
            .collection('places')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

    return snapshot.docs
        .map((doc) => PlaceModel.fromJson(_convertFirestoreDoc(doc)))
        .toList();
  }

  Future<List<PlaceModel>> filterPlacesByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('places')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs
        .map((doc) => PlaceModel.fromJson(_convertFirestoreDoc(doc)))
        .toList();
  }

  /// Helper to convert Firestore DocumentSnapshot to Map<String, dynamic>
  /// that fits PlaceModel.fromJson (handles GeoPoint conversion)
  Map<String, dynamic> _convertFirestoreDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Firestore GeoPoint to a nested map with latitude and longitude
    if (data['location'] is GeoPoint) {
      final geoPoint = data['location'] as GeoPoint;
      data['location'] = {
        'latitude': geoPoint.latitude,
        'longitude': geoPoint.longitude,
      };
    }
    return data;
  }
}
