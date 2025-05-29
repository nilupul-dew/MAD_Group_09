// lib/presentation/screens/search_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:hiking_app/presentation/screens/item/item_page.dart'; // Assumed GearItemDetailScreen is here
import 'package:hiking_app/domain/models/gear_item.dart'; // Still using Item as the model
import 'package:hiking_app/data/firebase_services/item/search_firestore_service.dart';
import 'package:hiking_app/presentation/widgets/item/gear_item_card.dart'; // Import your reusable widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchFirestoreService _searchService = SearchFirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Item> _allGearItems = []; // This will hold ALL gear items fetched once
  List<Item> _gearResults = []; // Stores the filtered gear items to display
  List<Map<String, dynamic>> _shopResults = [];
  List<Map<String, dynamic>> _recentSearches = [];
  // Keep _suggestedGearItems for displaying a *limited* set on initial load if desired,
  // separate from the full list. It will be fetched once.
  List<Item> _suggestedGearItems = [];

  String? _selectedCategory; // State variable for the selected category button

  // Define your categories for the filter buttons
  final List<String> _categories = [
    'All',
    'Backpack',
    'Poles',
    'Medical',
    'Clothing',
    'Cooking',
    'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecentSearches();
    _fetchAllAndSuggestedGearItems(); // MODIFIED: Single call to fetch all and limited suggested
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      // If search bar is cleared, and a category was selected, reset it
      if (_selectedCategory != null && _selectedCategory != 'All') {
        setState(() {
          _selectedCategory = null; // Clear category selection
        });
      }
      _fetchRecentSearches(); // Re-fetch recent searches if needed
      // When text is empty, and no category is selected, clear search results
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
    }
    _applyFilters(); // Always apply filters based on current text and category
  }

  Future<void> _fetchRecentSearches() async {
    final recentSearches = await _searchService.fetchRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
    });
  }

  // MODIFIED: Fetches all gear items for local filtering AND a limited set for initial suggestions
  Future<void> _fetchAllAndSuggestedGearItems() async {
    try {
      // Fetch ALL gear items for local filtering
      final QuerySnapshot allGearSnapshot =
          await _firestore.collection('gear_items').get();
      _allGearItems =
          allGearSnapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();

      // Fetch a LIMITED number of items for the "Suggested for You" section
      // This is separate from the full list for performance and relevance on initial load
      final QuerySnapshot suggestedSnapshot =
          await _firestore
              .collection('gear_items')
              .limit(6) // Fetch a limited number of items for display
              .orderBy(
                'name',
              ) // Or orderBy('rating', descending: true) or some other logic
              .get();
      _suggestedGearItems =
          suggestedSnapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();

      setState(() {
        // After fetching, apply filters to initialize _gearResults based on current state (empty search, no category)
        _applyFilters();
      });
    } catch (e) {
      print("Error fetching all and suggested gear items: $e");
      // Handle error, maybe show a message to the user
    }
  }

  // NEW: Method to apply local filters on _allGearItems
  void _applyFilters() {
    final keyword = _searchController.text.trim().toLowerCase();
    String? currentCategoryFilter = _selectedCategory?.toLowerCase();

    // If 'All' category button is selected, effectively no category filter
    if (currentCategoryFilter == 'all') {
      currentCategoryFilter = null;
    }

    // Filter from the comprehensive _allGearItems list
    List<Item> tempFilteredGear =
        _allGearItems.where((item) {
          final itemNameLower = item.name.toLowerCase();
          final itemCategoryLower = item.category.toLowerCase();

          // Category Filter Logic:
          // If a category button is selected, filter by that specific category.
          // Else, if the keyword itself is an exact category, filter by that category.
          // Otherwise, no category filter is applied at this stage for the item.
          bool categoryMatches = true;
          if (currentCategoryFilter != null) {
            categoryMatches = (itemCategoryLower == currentCategoryFilter);
          } else if (keyword.isNotEmpty &&
              _categories.map((c) => c.toLowerCase()).contains(keyword)) {
            // If the search keyword is an exact category name (e.g., "backpack"),
            // treat it as a category filter for the item.
            categoryMatches = (itemCategoryLower == keyword);
          }

          // Text Search Logic:
          // If the keyword is empty, or if the item name contains the keyword.
          // Special case: If the keyword was used as an exact category match (handled above),
          // then we don't also filter by name for that same keyword.
          bool nameMatches = true;
          if (keyword.isNotEmpty) {
            if (currentCategoryFilter != null) {
              // If a category button is selected, always apply name search to keyword within that category
              nameMatches = itemNameLower.contains(keyword);
            } else if (!(_categories
                .map((c) => c.toLowerCase())
                .contains(keyword))) {
              // If no category button is selected AND keyword is NOT an exact category,
              // then apply name search.
              nameMatches = itemNameLower.contains(keyword);
            }
            // If keyword *is* an exact category and no button is selected,
            // then nameMatches remains true because categoryMatches handles it.
          }

          return categoryMatches && nameMatches;
        }).toList();

    // For shops, we still use the SearchFirestoreService as they are separate collections
    // and we don't fetch all shops initially for efficiency.
    _searchService.searchShops(keyword).then((shops) {
      setState(() {
        _gearResults = tempFilteredGear;
        _shopResults = shops;
      });
    });
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      // If search is triggered with empty keyword, just ensure recent/suggested are displayed
      _fetchRecentSearches();
      setState(() {
        _gearResults = [];
        _shopResults = [];
      });
      return;
    }

    await _searchService.saveSearchTerm(keyword);
    _applyFilters(); // Trigger the local filter for gear and Firestore search for shops
  }

  Widget _buildRecentSearchTile(String term) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: InkWell(
        onTap: () {
          _searchController.text = term;
          _applyFilters(); // Apply filters when a recent search is tapped
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: const BoxDecoration(),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.grey[600], size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  term,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    // Condition to show Recent Searches + Suggested Gear (only when search bar is empty and no specific category is selected)
    final bool showInitialContent =
        _searchController.text.isEmpty &&
        (_selectedCategory == null || _selectedCategory == 'All');

    if (showInitialContent) {
      mainContent = ListView(
        children: [
          if (_recentSearches.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Recent Searches",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ..._recentSearches
              .map((s) => _buildRecentSearchTile(s['term'] as String))
              .toList(),

          if (_suggestedGearItems
              .isNotEmpty) // Use the separate suggested items list here
            const Padding(
              padding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 6.0),
              child: Text(
                "Suggested for You",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Important for nested scrolling
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children:
                  _suggestedGearItems // Display the limited suggested items
                      .map(
                        (item) => GearItemCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        GearItemDetailScreen(item: item),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 20),
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
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
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
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children:
                  _gearResults // Display the filtered results
                      .map(
                        (item) => GearItemCard(
                          item: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        GearItemDetailScreen(item: item),
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
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
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

          // Category Filter Buttons Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
            child: SizedBox(
              // ADD THIS SIZEDBOX
              width:
                  MediaQuery.of(context)
                      .size
                      .width, // Or just double.infinity, but MediaQuery is more precise
              child: Scrollbar(
                thumbVisibility: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _categories.map((category) {
                          final bool isSelected =
                              _selectedCategory == category ||
                              (_selectedCategory == null && category == 'All');
                          final Random random = Random();
                          Color randomLightColor;
                          if (isSelected) {
                            randomLightColor =
                                Theme.of(
                                  context,
                                ).primaryColor; // Keep primary color for selected
                          } else {
                            // Generate a random light color.
                            // Adjust the random values (e.g., 200 to 255 for Red, Green, Blue)
                            // to control the lightness. Higher values mean lighter colors.
                            randomLightColor = Color.fromARGB(
                              255, // Full opacity
                              random.nextInt(56) + 200, // R between 200-255
                              random.nextInt(56) + 200, // G between 200-255
                              random.nextInt(56) + 200, // B between 200-255
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 4,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory =
                                      (category == 'All') ? null : category;
                                  _searchController.clear();
                                });
                                _applyFilters();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: randomLightColor,

                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ), // END SIZEDBOX
          ),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
