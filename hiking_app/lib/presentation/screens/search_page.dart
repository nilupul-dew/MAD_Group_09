// lib/presentation/screens/search_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/screens/item_page.dart';
import 'package:hiking_app/domain/models/gear_item.dart'; // Still using Item as the model
import 'package:hiking_app/data/firebase_services/search_firestore_service.dart';
import 'package:hiking_app/presentation/widgets/gear_item_card.dart'; // NEW: Import your reusable widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchFirestoreService _searchService = SearchFirestoreService();

  List<Item> _gearResults = [];
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
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
      return;
    }

    await _searchService.saveSearchTerm(keyword);
    _fetchRecentSearches();

    final gearMatches = await _searchService.searchGearItems(keyword);
    final shopMatches = await _searchService.searchShops(keyword);

    setState(() {
      _gearResults = gearMatches;
      _shopResults = shopMatches;
    });
  }

  // Removed _buildGearCard as it's now a separate widget

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
                      onSubmitted: (_) => _performSearch(),
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
          if (_gearResults.isEmpty && _shopResults.isEmpty && _searchController.text.isEmpty)
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
          else if (_gearResults.isEmpty && _shopResults.isEmpty && _searchController.text.isNotEmpty)
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
                      children: _gearResults
                          .map(
                            (item) => GearItemCard( // NEW: Use your reusable widget here
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GearItemDetailScreen(item: item),
                                  ),
                                );
                              },
                            ),
                          )
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}