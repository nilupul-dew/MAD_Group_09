import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/place_model.dart';

class FirestorePlaceService {
  final _collection = FirebaseFirestore.instance.collection('places');

  Future<List<Place>> fetchAllPlaces() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Place.fromMap(doc.data())).toList();
  }

  Future<List<Place>> searchPlaces(String query) async {
    final snapshot =
        await _collection
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

    return snapshot.docs.map((doc) => Place.fromMap(doc.data())).toList();
  }

  Future<List<Place>> filterByCategory(String category) async {
    final snapshot =
        await _collection.where('category', isEqualTo: category).get();

    return snapshot.docs.map((doc) => Place.fromMap(doc.data())).toList();
  }
}
