// lib/presentation/screens/search_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for Timestamp if you use it directly
import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/screens/item_page.dart'; // Your Item Detail Page
import 'package:hiking_app/domain/models/gear_item.dart'; // Import your existing Item model
import 'package:hiking_app/data/firebase_services/search_firestore_service.dart'; // New: Import SearchFirestoreService

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchFirestoreService _searchService =
      SearchFirestoreService(); // Use the new service

  List<Item> _gearResults = []; // Changed to List<Item>
  List<Map<String, dynamic>> _shopResults = [];
  List<Map<String, dynamic>> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentSearches();
  }

  Future<void> _fetchRecentSearches() async {
    final recentSearches = await _searchService.fetchRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
    });
  }

  Future<void> _performSearch() async {
    final keyword =
        _searchController.text.trim(); // Keep original casing for saving
    if (keyword.isEmpty) {
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
      return;
    }

    await _searchService.saveSearchTerm(keyword);
    _fetchRecentSearches(); // Refresh recent list

    final gearMatches = await _searchService.searchGearItems(keyword);
    final shopMatches = await _searchService.searchShops(keyword);

    setState(() {
      _gearResults = gearMatches;
      _shopResults = shopMatches;
    });
  }

  // Changed parameter type to Item
  Widget _buildGearCard(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // FIX: Pass the Item object directly.
            // The ItemPage (GearItemDetailScreen) no longer expects 'itemId' separately.
            builder:
                (context) => GearItemDetailScreen(
                  // Use GearItemDetailScreen as per your confirmation
                  item: item, // Pass the Item object
                ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                item.imageUrl, // Use item.imageUrl
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name, // Use item.name
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Capacity: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${item.specs['capacity'] ?? 'N/A'}',
                          ), // Access specs
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Available: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${item.availableQty}',
                          ), // Use item.availableQty
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Charge per day: Rs.${item.rentPricePerDay}", // Use item.rentPricePerDay
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchTile(String term) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(term),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _searchController.text = term;
        _performSearch();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search here...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted:
                          (_) =>
                              _performSearch(), // Trigger search on keyboard "done"
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _performSearch,
                  ),
                ],
              ),
            ),
          ),
          if (_gearResults.isEmpty &&
              _shopResults.isEmpty &&
              _searchController.text.isEmpty)
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "Recent Searches",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ..._recentSearches
                      .map((s) => _buildRecentSearchTile(s['term']))
                      .toList(),
                ],
              ),
            )
          else if (_gearResults.isEmpty &&
              _shopResults.isEmpty &&
              _searchController.text.isNotEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (_gearResults.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6,
                      ),
                      child: Text(
                        "Gear Items",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      children:
                          _gearResults
                              .map((item) => _buildGearCard(item))
                              .toList(),
                    ),
                  ),
                  if (_shopResults.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6,
                      ),
                      child: Text(
                        "Shops",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ..._shopResults.map(
                    (shop) => ListTile(
                      leading: const Icon(Icons.store),
                      title: Text(shop['name'] ?? ''),
                      // onTap: () { /* Navigate to shop detail if you have one */ },
                    ),
                  ),
                  const SizedBox(height: 20), // Add some spacing at the bottom
                ],
              ),
            ),
        ],
      ),
    );
  }
}
