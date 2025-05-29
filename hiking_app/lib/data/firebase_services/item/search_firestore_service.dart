// lib/services/search_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/domain/models/gear_item.dart'; // Import your existing Item model

class SearchFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch recent searches
  Future<List<Map<String, dynamic>>> fetchRecentSearches() async {
    final snapshot = await _firestore
        .collection('recent_searches')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => {'term': doc['term']}).toList();
  }

  // Save a search term
  Future<void> saveSearchTerm(String term) async {
    // Check if the term already exists to avoid duplicates or update timestamp
    final existingSearches = await _firestore
        .collection('recent_searches')
        .where('term', isEqualTo: term)
        .limit(1)
        .get();

    if (existingSearches.docs.isNotEmpty) {
      // Update timestamp if term exists
      await existingSearches.docs.first.reference.update({'timestamp': Timestamp.now()});
    } else {
      // Add new term
      await _firestore.collection('recent_searches').add({
        'term': term,
        'timestamp': Timestamp.now(),
      });
    }
  }

  // Search for gear items
  Future<List<Item>> searchGearItems(String keyword) async {
    final gearSnapshot = await _firestore.collection('gear_items').get(); // You might want to add .where() clauses for better performance if possible

    final gearMatches = gearSnapshot.docs
        .where(
          (doc) => (doc['name_lowercase'] ?? '')
              .toString()
              .contains(keyword.toLowerCase()),
        )
        .map((doc) => Item.fromFirestore(doc))
        .toList();

    return gearMatches;
  }

  // Search for shops
  Future<List<Map<String, dynamic>>> searchShops(String keyword) async {
    final shopSnapshot = await _firestore.collection('shops').get(); // Consider adding indexes or full-text search for large datasets

    final shopMatches = shopSnapshot.docs
        .where(
          (doc) => (doc['name_lowercase'] ?? '') // Assuming 'name_lowercase' for shops as well
              .toString()
              .contains(keyword.toLowerCase()),
        )
        .map((doc) => doc.data())
        .toList();

    return shopMatches;
  }
}