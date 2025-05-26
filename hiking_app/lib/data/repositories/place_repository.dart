import 'package:hiking_app/data/firebase_services/firestore_place_service.dart';
import 'package:hiking_app/domain/models/place_model.dart';

class PlaceRepository {
  final FirestorePlaceService _service = FirestorePlaceService();

  Future<List<PlaceModel>> getAllPlaces() {
    return _service.getAllPlaces();
  }

  Future<List<PlaceModel>> searchPlaces(String query) {
    return _service.searchPlaces(query);
  }

  Future<List<PlaceModel>> filterPlacesByCategory(String category) {
    return _service.filterPlacesByCategory(category);
  }
}
