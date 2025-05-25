import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _gearResults = [];
  List<Map<String, dynamic>> _shopResults = [];
  List<Map<String, dynamic>> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentSearches();
  }

  Future<void> _fetchRecentSearches() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('recent_searches')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

    setState(() {
      _recentSearches =
          snapshot.docs.map((doc) => {'term': doc['term']}).toList();
    });
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return;

    // Save search
    await FirebaseFirestore.instance.collection('recent_searches').add({
      'term': keyword,
      'timestamp': Timestamp.now(),
    });

    _fetchRecentSearches(); // Refresh recent list

    final gearSnapshot =
        await FirebaseFirestore.instance.collection('gear_items').get();

    final shopSnapshot =
        await FirebaseFirestore.instance.collection('shops').get();

    final gearMatches =
        gearSnapshot.docs
            .where(
              (doc) => (doc['name_lowercase'] ?? '').toString().contains(
                keyword.toLowerCase(),
              ),
            )
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

    final shopMatches =
        shopSnapshot.docs
            .where(
              (doc) => (doc['name_lowercase'] ?? '').toString().contains(
                keyword.toLowerCase(),
              ),
            )
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

    setState(() {
      _gearResults = gearMatches;
      _shopResults = shopMatches;
    });
  }

  Widget _buildGearCard(Map<String, dynamic> data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              data['image'] ?? 'https://via.placeholder.com/150',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data['name'] ?? '',
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
                        text: "Capacity: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${data['specs']?['capacity'] ?? 'N/A'}"),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Charge per day: Rs.${data['rent_price_per_day'] ?? '0.00'}",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Available: ${data['available_quantity'] ?? '0'} items",
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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
                boxShadow: [
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
          if (_gearResults.isEmpty && _shopResults.isEmpty)
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
            ),
          if (_gearResults.isNotEmpty || _shopResults.isNotEmpty)
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
                      childAspectRatio: 0.72,
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
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
