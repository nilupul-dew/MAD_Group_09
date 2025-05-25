import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'Mountains',
    'Waterfalls',
    'Lakes',
    'Beaches',
    'Forests',
  ];
  List<String> selectedCategories = [];

  void _onSearch() {
    final query = _searchController.text;
    print('Search query: $query');
    // TODO: Connect Firestore search logic here
  }

  void _onFilterPressed() {
    // TODO: Open filter dialog or screen
    print('Filter button pressed');
  }

  void _onCategorySelected(bool selected, String category) {
    setState(() {
      if (selected) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
    print('Selected categories: $selectedCategories');
    // TODO: Filter list by selected categories
  }

  Widget _buildListTile(String title, String subtitle, String imageUrl) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // TODO: Navigate to detail screen for this item
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Campsites & Hiking Areas'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar + Filter button row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search here...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _onFilterPressed,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Categories horizontal filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected:
                        (selected) => _onCategorySelected(selected, category),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Most Famous Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Most Famous',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            // Famous hiking/campsite list (scrollable)
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    'Knuckles Range',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=80&q=80',
                  ),
                  _buildListTile(
                    'Ella Rock',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=80&q=80',
                  ),
                  _buildListTile(
                    'Adam’s Peak',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=80&q=80',
                  ),
                  _buildListTile(
                    'Pidurangala Rock',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=80&q=80',
                  ),
                  _buildListTile(
                    'Horton Plains',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=80&q=80',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
