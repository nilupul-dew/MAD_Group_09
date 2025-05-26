import 'package:flutter/material.dart';
import '../../../domain/models/place_model.dart';
import '../../../data/firebase_services/firestore_place_service.dart';

class PlaceViewModel extends ChangeNotifier {
  final FirestorePlaceService _firestoreService = FirestorePlaceService();

  List<PlaceModel> _allPlaces = [];
  List<PlaceModel> _filteredPlaces = [];

  List<PlaceModel> get places => _filteredPlaces;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  List<String> _selectedCategories = [];

  Future<void> loadPlaces() async {
    _isLoading = true;
    notifyListeners();

    _allPlaces = await _firestoreService.getAllPlaces();

    _filteredPlaces = _allPlaces;

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void updateSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPlaces =
        _allPlaces.where((place) {
          final matchesQuery =
              _searchQuery.isEmpty ||
              place.name.toLowerCase().contains(_searchQuery) ||
              place.locationName.toLowerCase().contains(_searchQuery) ||
              place.type.toLowerCase().contains(_searchQuery);

          final matchesCategory =
              _selectedCategories.isEmpty ||
              _selectedCategories.contains(place.category);

          return matchesQuery && matchesCategory;
        }).toList();

    notifyListeners();
  }
}
