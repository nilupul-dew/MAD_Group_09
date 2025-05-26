// import 'package:flutter/material.dart';
// import '../../../domain/models/place_model.dart';
// import '../../../data/firebase_services/firestore_place_service.dart';

// class PlaceViewModel extends ChangeNotifier {
//   final FirestorePlaceService _firestoreService = FirestorePlaceService();

//   List<PlaceModel> _allPlaces = [];
//   List<PlaceModel> _filteredPlaces = [];
//   List<PlaceModel> get places => _filteredPlaces;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _searchQuery = '';
//   List<String> _selectedCategories = [];

//   List<String> get selectedCategories => _selectedCategories;

//   Future<void> loadPlaces() async {
//     _isLoading = true;
//     notifyListeners();

//     _allPlaces = await _firestoreService.getAllPlaces();

//     _filteredPlaces = _allPlaces;

//     _isLoading = false;
//     notifyListeners();
//   }

//   void updateSearchQuery(String query) {
//     _searchQuery = query.toLowerCase();
//     _applyFilters();
//   }

//   void updateSelectedCategories(List<String> categories) {
//     _selectedCategories = categories;
//     _applyFilters();
//   }

//   void _applyFilters() {
//     _filteredPlaces =
//         _allPlaces.where((place) {
//           final matchesQuery =
//               _searchQuery.isEmpty ||
//               place.name.toLowerCase().contains(_searchQuery) ||
//               place.locationName.toLowerCase().contains(_searchQuery) ||
//               place.type.toLowerCase().contains(_searchQuery);

//           final matchesCategory =
//               _selectedCategories.isEmpty ||
//               _selectedCategories.contains(place.category);

//           return matchesQuery && matchesCategory;
//         }).toList();

//     notifyListeners();
//   }
// }
//----------best down-------------//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../domain/models/place_model.dart';
// import '../../../data/firebase_services/firestore_place_service.dart';

// class PlaceViewModel extends ChangeNotifier {
//   final FirestorePlaceService _firestoreService = FirestorePlaceService();

//   List<PlaceModel> _allPlaces = [];
//   List<PlaceModel> _filteredPlaces = [];
//   List<PlaceModel> get places => _filteredPlaces;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _searchQuery = '';
//   List<String> _selectedCategories = [];

//   List<String> get selectedCategories => _selectedCategories;

//   List<String> _searchHistory = [];
//   List<String> get searchHistory => _searchHistory;

//   PlaceViewModel() {
//     loadSearchHistory();
//   }

//   Future<void> loadPlaces() async {
//     _isLoading = true;
//     notifyListeners();

//     _allPlaces = await _firestoreService.getAllPlaces();
//     _filteredPlaces = _allPlaces;

//     _isLoading = false;
//     notifyListeners();
//   }

//   void updateSearchQuery(String query) {
//     _searchQuery = query.toLowerCase();
//     _applyFilters();
//   }

//   void updateSelectedCategories(List<String> categories) {
//     _selectedCategories = categories;
//     _applyFilters();
//   }

//   void _applyFilters() {
//     _filteredPlaces =
//         _allPlaces.where((place) {
//           final matchesQuery =
//               _searchQuery.isEmpty ||
//               place.name.toLowerCase().contains(_searchQuery) ||
//               place.locationName.toLowerCase().contains(_searchQuery) ||
//               place.type.toLowerCase().contains(_searchQuery);

//           final matchesCategory =
//               _selectedCategories.isEmpty ||
//               _selectedCategories.contains(place.category) ||
//               _selectedCategories.contains(place.type);

//           return matchesQuery && matchesCategory;
//         }).toList();

//     notifyListeners();
//   }

//   // --- Search history persistence ---

//   Future<void> loadSearchHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     _searchHistory = prefs.getStringList('search_history') ?? [];
//     notifyListeners();
//   }

//   Future<void> addSearchTerm(String term) async {
//     final prefs = await SharedPreferences.getInstance();

//     if (_searchHistory.contains(term)) {
//       _searchHistory.remove(term);
//     }
//     _searchHistory.insert(0, term);

//     if (_searchHistory.length > 10) {
//       _searchHistory = _searchHistory.sublist(0, 10);
//     }

//     await prefs.setStringList('search_history', _searchHistory);
//     notifyListeners();
//   }
// }
// --------------------------------------//
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

          final matchesType =
              _selectedTypes.isEmpty || _selectedTypes.contains(place.type);

          return matchesQuery && matchesCategory && matchesType;
        }).toList();

    notifyListeners();
  }
}
