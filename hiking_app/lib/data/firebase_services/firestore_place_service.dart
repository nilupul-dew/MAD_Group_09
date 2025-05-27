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

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PlaceModel.fromJson(data);
    }).toList();
  }

  Future<List<PlaceModel>> searchPlaces(String query) async {
    final snapshot =
        await _firestore
            .collection('places')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

    return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
  }

  Future<List<PlaceModel>> filterPlacesByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('places')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs.map((doc) => PlaceModel.fromJson(doc.data())).toList();
  }

  Future<void> addPlace(PlaceModel place) async {
    await _firestore.collection('places').add(place.toJson());
  }

  Future<void> updatePlace(String docId, PlaceModel place) async {
    await _firestore.collection('places').doc(docId).update(place.toJson());
  }

  Future<void> deletePlace(String docId) async {
    await _firestore.collection('places').doc(docId).delete();
  }
}
