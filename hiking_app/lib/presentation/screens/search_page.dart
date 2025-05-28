// lib/presentation/screens/search_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/screens/item_page.dart'; // Assumed GearItemDetailScreen is here
import 'package:hiking_app/domain/models/gear_item.dart'; // Still using Item as the model
import 'package:hiking_app/data/firebase_services/search_firestore_service.dart';
import 'package:hiking_app/presentation/widgets/gear_item_card.dart'; // Import your reusable widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchFirestoreService _searchService = SearchFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Added Firestore instance

  List<Item> _gearResults = [];
  List<Map<String, dynamic>> _shopResults = [];
  List<Map<String, dynamic>> _recentSearches = [];
  List<Item> _suggestedGearItems = []; // NEW: List to hold suggested items

  @override
  void initState() {
    super.initState();
    _fetchRecentSearches();
    _fetchSuggestedGearItems(); // NEW: Fetch suggested items on init
    // Add a listener to handle search bar text changes
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  // NEW: Listener for search bar text changes
  void _onSearchTextChanged() {
    // This will trigger a rebuild when text changes,
    // allowing the conditional UI to update.
    // If text becomes empty, we might re-fetch recent searches
    // and suggested items, ensuring data is fresh.
    if (_searchController.text.isEmpty) {
      _fetchRecentSearches(); // Re-fetch recent searches
      _fetchSuggestedGearItems(); // Re-fetch suggested items
      // Also clear any previous search results if the user clears the bar
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
    }
    setState(() {}); // Trigger rebuild to update UI based on _searchController.text
  }

  Future<void> _fetchRecentSearches() async {
    final recentSearches = await _searchService.fetchRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
    });
  }

  // NEW: Function to fetch a few random/suggested gear items
  Future<void> _fetchSuggestedGearItems() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('gear_items')
          .limit(6) // Fetch a limited number of items
          // .orderBy('rating', descending: true) // Example: order by rating
          .get();

      final List<Item> items = querySnapshot.docs.map((doc) {
        return Item.fromFirestore(doc); // Assuming your Item.fromFirestore constructor
      }).toList();

      setState(() {
        _suggestedGearItems = items;
      });
    } catch (e) {
      print("Error fetching suggested gear items: $e");
      // Handle error, maybe show a message to the user
    }
  }


  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
      // If search is triggered with empty keyword, just ensure recent/suggested are displayed
      _fetchRecentSearches();
      _fetchSuggestedGearItems();
      return;
    }

    await _searchService.saveSearchTerm(keyword);
    // Don't re-fetch recent searches here, as we are now displaying results.
    // _fetchRecentSearches(); // Removed this line

    final gearMatches = await _searchService.searchGearItems(keyword);
    final shopMatches = await _searchService.searchShops(keyword);

    setState(() {
      _gearResults = gearMatches;
      _shopResults = shopMatches;
    });
  }

  Widget _buildRecentSearchTile(String term) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ), // Reduced vertical padding
      child: InkWell(
        onTap: () {
          _searchController.text = term;
          _performSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ), // Padding inside the tappable area
          decoration: const BoxDecoration(
            // No color, no border, no shadow for a minimalistic look
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.grey[600],
                size: 20,
              ), // Styled icon, slightly larger
              const SizedBox(width: 16), // Space between icon and text
              Expanded(
                child: Text(
                  term,
                  style: const TextStyle(
                    fontSize: 16,
                    color:
                        Colors.black87, // Slightly darker text for search terms
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Optionally add an arrow to indicate "fill" or "go"
              // Icon(Icons.arrow_upward, size: 20, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which content to display below the search bar
    Widget mainContent;

    // Condition to show Recent Searches + Suggested Gear
    if (_searchController.text.isEmpty) {
      mainContent = ListView(
        children: [
          if (_recentSearches.isNotEmpty)
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
              .map((s) => _buildRecentSearchTile(s['term'] as String))
              .toList(),
          
          if (_suggestedGearItems.isNotEmpty) // Only show if there are suggested items
            const Padding(
              padding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 6.0), // Top padding to separate
              child: Text(
                "Suggested for You",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Important for nested scrolling
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 8, // Add spacing between cards
              mainAxisSpacing: 8, // Add spacing between cards
              children: _suggestedGearItems
                  .map(
                    (item) => GearItemCard(
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
          const SizedBox(height: 20), // Extra space at the bottom of the list
        ],
      );
    }
    // Condition to show "No results found"
    else if (_gearResults.isEmpty && _shopResults.isEmpty) {
      mainContent = const Center(
        child: Text(
          "No results found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    // Condition to show actual search results
    else {
      mainContent = ListView(
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
              crossAxisSpacing: 8, // Add spacing between cards
              mainAxisSpacing: 8, // Add spacing between cards
              children: _gearResults
                  .map(
                    (item) => GearItemCard(
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
      );
    }

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
          // The main content area changes based on search state
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}