import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/location-firebase_services/firestore_place_service.dart';
import 'package:hiking_app/domain/models/location-models/place_model.dart';

class PlaceViewModel extends ChangeNotifier {
  final FirestorePlaceService _firestoreService = FirestorePlaceService();

  List<PlaceModel> _allPlaces = [];
  List<PlaceModel> _filteredPlaces = [];

  List<PlaceModel> get places => _filteredPlaces;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedTypes = [];
  List<String> get selectedTypes => _selectedTypes;

  List<String> _searchHistory = [];
  List<String> get searchHistory => _searchHistory;

  List<String> get selectedCategories => _selectedCategories;

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
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    }
    _applyFilters();
  }

  void updateSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    _applyFilters();
  }

  void updateSelectedTypes(List<String> types) {
    _selectedTypes = types;
    _applyFilters();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPlaces = _allPlaces.where((place) {
      final matchesQuery = _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery) ||
          place.locationName.toLowerCase().contains(_searchQuery) ||
          place.type.toLowerCase().contains(_searchQuery);

      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(place.category);

      final matchesType =
          _selectedTypes.isEmpty || _selectedTypes.contains(place.type);

      return matchesQuery && matchesCategory && matchesType;
    }).toList();

    notifyListeners();
  }
}
