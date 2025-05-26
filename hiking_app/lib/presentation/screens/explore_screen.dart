import 'package:flutter/material.dart';

// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];

//   final Map<String, Color> categoryColors = {
//     'Mountains': Color.fromARGB(255, 168, 85, 18), // light brown pastel
//     'Waterfalls': Color.fromARGB(255, 136, 171, 216), // light blue pastel
//     'Lakes': Color.fromARGB(255, 123, 156, 124), // light green pastel
//     'Beaches': Color.fromARGB(255, 151, 125, 99), // light orange pastel
//     'Forests': Color.fromARGB(255, 32, 100, 95), // teal pastel
//   };

//   final Map<String, IconData> categoryIcons = {
//     'Mountains': Icons.terrain,
//     'Waterfalls': Icons.waterfall_chart,
//     'Lakes': Icons.water,
//     'Beaches': Icons.beach_access,
//     'Forests': Icons.park,
//   };

//   List<String> selectedCategories = [];

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     print('Filter button pressed');
//     // TODO: Open filter dialog or screen
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   // New modern card style replacing _buildListTile
//   Widget _buildCardItem(String title, String subtitle, String imageUrl) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       height: 100,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: NetworkImage(imageUrl),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.black.withOpacity(0.3),
//             BlendMode.darken,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           // TODO: Navigate to detail screen for this item
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                         shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(
//                   bottom: 25.0,
//                 ), // Align arrow vertically with text bottom
//                 child: const Icon(
//                   Icons.arrow_forward_ios,
//                   color: Colors.white70,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Campsites & Hiking Areas',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color.fromARGB(255, 24, 21, 44),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button row
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 1,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Categories horizontal filter chips with colors and icons
//             SizedBox(
//               height: 75,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   final chipColor =
//                       categoryColors[category] ?? Colors.grey.shade300;
//                   final chipIcon = categoryIcons[category] ?? Icons.category;

//                   return FilterChip(
//                     label: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           chipIcon,
//                           color: isSelected ? Colors.white : chipColor,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(category),
//                       ],
//                     ),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                     selectedColor: chipColor,
//                     backgroundColor: chipColor.withOpacity(0.3),
//                     checkmarkColor: Colors.white,
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 15),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 25),

//             // Famous hiking/campsite list (scrollable) using modern cards
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildCardItem(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://media.gettyimages.com/id/1245433305/photo/a-night-view-of-sri-pada-on-january-9-in-maskeliya-sri-lanka-adams-peak-or-the-sri-pada-is-an.jpg?s=612x612&w=0&k=20&c=2hxaln8sJNzaRSIQe2Ra0FZ4dWZ-UJY7GT-ib4A9iQ8=',
//                   ),
//                   _buildCardItem(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://media.gettyimages.com/id/992296464/photo/sri-lankas-world-heritage-site-sigiriya-or-sihigiriya.jpg?s=612x612&w=0&k=20&c=NHTizDy5Ct3B_ywlv06PADwyqdvpSJyFciTjHLtiwsg=',
//                   ),
//                   _buildCardItem(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   // _buildCardItem(
//                   //   'Horton Plains',
//                   //   'Sri Lanka',
//                   //   'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }

//--------------------------above best------------------------//

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final Map<String, Color> categoryColors = {
    'Mountains': Color.fromARGB(255, 168, 85, 18), // light brown pastel
    'Waterfalls': Color.fromARGB(255, 136, 171, 216), // light blue pastel
    'Lakes': Color.fromARGB(255, 123, 156, 124), // light green pastel
    'Beaches': Color.fromARGB(255, 151, 125, 99), // light orange pastel
    'Forests': Color.fromARGB(255, 32, 100, 95), // teal pastel
  };

  final Map<String, IconData> categoryIcons = {
    'Mountains': Icons.terrain,
    'Waterfalls': Icons.waterfall_chart,
    'Lakes': Icons.water,
    'Beaches': Icons.beach_access,
    'Forests': Icons.park,
  };

  List<String> selectedCategories = [];

  void _onSearch() {
    final query = _searchController.text;
    print('Search query: $query');
    // TODO: Connect Firestore search logic here
  }

  void _onFilterPressed() {
    print('Filter button pressed');
    // TODO: Open filter dialog or screen
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

  // Updated modern card style with small white badge icon for type
  Widget _buildCardItem(
    String title,
    String subtitle,
    String imageUrl,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to detail screen for this item
        },
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 70,
                      ), // Padding for badge space
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(
                      0,
                      0.5,
                    ), // Adjust x,y to position precisely
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(221, 252, 252, 252),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Small white badge with type icon at top-left
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  type == 'Hiking Area'
                      ? Icons.directions_walk
                      : FontAwesomeIcons
                          .campground, // Changed to default camping icon
                  size: 22,
                  color: const Color.fromARGB(221, 2, 43, 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campsites & Hiking Areas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 24, 21, 44),
        centerTitle: true,
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
                      vertical: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Categories horizontal filter chips with colors and icons
            SizedBox(
              height: 75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategories.contains(category);
                  final chipColor =
                      categoryColors[category] ?? Colors.grey.shade300;
                  final chipIcon = categoryIcons[category] ?? Icons.category;

                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          chipIcon,
                          color: isSelected ? Colors.white : chipColor,
                        ),
                        const SizedBox(width: 6),
                        Text(category),
                      ],
                    ),
                    selected: isSelected,
                    onSelected:
                        (selected) => _onCategorySelected(selected, category),
                    selectedColor: chipColor,
                    backgroundColor: chipColor.withOpacity(0.3),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // Most Famous Section Title
            Align(
              alignment: Alignment.center,
              child: Text(
                'Most Famous',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 25),

            // Famous hiking/campsite list (scrollable) using modern cards
            Expanded(
              child: ListView(
                children: [
                  _buildCardItem(
                    'Knuckles Range',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
                    'Hiking Area',
                  ),
                  _buildCardItem(
                    'Ella Rock',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=600&q=80',
                    'Hiking Area',
                  ),
                  _buildCardItem(
                    'Adam’s Peak',
                    'Sri Lanka',
                    'https://media.gettyimages.com/id/1245433305/photo/a-night-view-of-sri-pada-on-january-9-in-maskeliya-sri-lanka-adams-peak-or-the-sri-pada-is-an.jpg?s=612x612&w=0&k=20&c=2hxaln8sJNzaRSIQe2Ra0FZ4dWZ-UJY7GT-ib4A9iQ8=',
                    'Hiking Area',
                  ),
                  _buildCardItem(
                    'Pidurangala Rock',
                    'Sri Lanka',
                    'https://media.gettyimages.com/id/992296464/photo/sri-lankas-world-heritage-site-sigiriya-or-sihigiriya.jpg?s=612x612&w=0&k=20&c=NHTizDy5Ct3B_ywlv06PADwyqdvpSJyFciTjHLtiwsg=',
                    'Campsite',
                  ),
                  _buildCardItem(
                    'Horton Plains',
                    'Sri Lanka',
                    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
                    'Campsite',
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

//------------------------------------------------------------//
// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];
//   List<String> selectedCategories = [];

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     // TODO: Open filter dialog or screen
//     print('Filter button pressed');
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   Widget _buildListTile(String title, String subtitle, String imageUrl) {
//     return ListTile(
//       leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
//       title: Text(title),
//       subtitle: Text(subtitle),
//       trailing: const Icon(Icons.arrow_forward_ios),
//       onTap: () {
//         // TODO: Navigate to detail screen for this item
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Explore Campsites & Hiking Areas'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button row
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Categories horizontal filter chips
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   return FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Famous hiking/campsite list (scrollable)
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildListTile(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=80&q=80',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }
//-------------------------------------------------//
// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];
//   List<String> selectedCategories = [];

//   final Map<String, Color> categoryColors = {
//     'Mountains': Color(0xFFD7C0AE), // light brown pastel
//     'Waterfalls': Color(0xFFABCFFF), // light blue pastel
//     'Lakes': Color(0xFFC8E6C9), // light green pastel
//     'Beaches': Color(0xFFFFD9B3), // light orange pastel
//     'Forests': Color(0xFFB2DFDB), // teal pastel
//   };

//   final Map<String, IconData> categoryIcons = {
//     'Mountains': Icons.terrain,
//     'Waterfalls': Icons.waterfall_chart,
//     'Lakes': Icons.water,
//     'Beaches': Icons.beach_access,
//     'Forests': Icons.park,
//   };

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     print('Filter button pressed');
//     // TODO: Open filter dialog or screen
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   Widget _buildListTile(String title, String subtitle, String imageUrl) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.85),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
//         title: Text(title),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios),
//         onTap: () {
//           // TODO: Navigate to detail screen for this item
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Explore Campsites & Hiking Areas'),
//         backgroundColor: Colors.green,
//         elevation: 0,
//       ),
//       body: Container(
//         color: Colors.grey[100]?.withOpacity(0.95),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button row
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white.withOpacity(0.9),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Categories horizontal filter chips
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   return FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                     avatar: Icon(
//                       categoryIcons[category],
//                       color:
//                           isSelected ? Colors.white : categoryColors[category],
//                     ),
//                     backgroundColor: categoryColors[category]!.withOpacity(
//                       0.15,
//                     ),
//                     selectedColor: categoryColors[category]!.withOpacity(0.6),
//                     showCheckmark: false,
//                     labelStyle: TextStyle(
//                       color:
//                           isSelected ? Colors.white : categoryColors[category],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Famous hiking/campsite list (scrollable)
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildListTile(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=80&q=80',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//------------------------------------------------//

// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];
//   List<String> selectedCategories = [];

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     print('Filter button pressed');
//     // TODO: Open filter dialog or screen
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   Widget _buildCardItem(String title, String subtitle, String imageUrl) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       height: 120,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: NetworkImage(imageUrl),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.black.withOpacity(0.3),
//             BlendMode.darken,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           // TODO: Navigate to detail screen for this item
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Align(
//             alignment: Alignment.bottomLeft,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Explore Campsites & Hiking Areas'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Categories horizontal filter chips
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   return FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Famous hiking/campsite list (scrollable)
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildCardItem(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }
//---------------------------------------------------------//

// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];

//   List<String> selectedCategories = [];

//   final Map<String, Color> categoryColors = {
//     'Mountains': Color(0xFFD7C0AE), // light brown pastel
//     'Waterfalls': Color(0xFFABCFFF), // light blue pastel
//     'Lakes': Color(0xFFC8E6C9), // light green pastel
//     'Beaches': Color(0xFFFFD9B3), // light orange pastel
//     'Forests': Color(0xFFB2DFDB), // teal pastel
//   };

//   final Map<String, IconData> categoryIcons = {
//     'Mountains': Icons.terrain,
//     'Waterfalls': Icons.waterfall_chart,
//     'Lakes': Icons.water,
//     'Beaches': Icons.beach_access,
//     'Forests': Icons.park,
//   };

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     print('Filter button pressed');
//     // TODO: Open filter dialog or screen
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   Widget _buildCardItem(String title, String subtitle, String imageUrl) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       height: 100, // Reduced height for a bit smaller cards
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: NetworkImage(imageUrl),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.black.withOpacity(0.3),
//             BlendMode.darken,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           // TODO: Navigate to detail screen for this item
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                         shadows: [Shadow(blurRadius: 5, color: Colors.black)],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.white70,
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Explore Campsites & Hiking Areas'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Categories horizontal filter chips with colors and icons
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   return FilterChip(
//                     label: Text(category),
//                     avatar: Icon(
//                       categoryIcons[category],
//                       size: 20,
//                       color: isSelected ? Colors.white : Colors.black54,
//                     ),
//                     selectedColor: categoryColors[category]?.withOpacity(0.8),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Famous hiking/campsite list (scrollable) with modern cards
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildCardItem(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=600&q=80',
//                   ),
//                   _buildCardItem(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }

//--------------------------------------------------------//

// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];

//   final Map<String, Color> categoryColors = {
//     'Mountains': Color(0xFFD7C0AE), // light brown pastel
//     'Waterfalls': Color(0xFFABCFFF), // light blue pastel
//     'Lakes': Color(0xFFC8EFC9), // light green pastel
//     'Beaches': Color(0xFFFFFD9B3), // light orange pastel
//     'Forests': Color(0xFFB2DFDB), // teal pastel
//   };

//   final Map<String, IconData> categoryIcons = {
//     'Mountains': Icons.terrain,
//     'Waterfalls': Icons.waterfall_chart,
//     'Lakes': Icons.water,
//     'Beaches': Icons.beach_access,
//     'Forests': Icons.park,
//   };

//   List<String> selectedCategories = [];

//   void _onSearch() {
//     final query = _searchController.text;
//     print('Search query: $query');
//     // TODO: Connect Firestore search logic here
//   }

//   void _onFilterPressed() {
//     print('Filter button pressed');
//     // TODO: Open filter dialog or screen
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });
//     print('Selected categories: $selectedCategories');
//     // TODO: Filter list by selected categories
//   }

//   Widget _buildListTile(String title, String subtitle, String imageUrl) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 10,
//         ),
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.network(
//             imageUrl,
//             width: 70,
//             height: 70,
//             fit: BoxFit.cover,
//           ),
//         ),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios),
//         onTap: () {
//           // TODO: Navigate to detail screen for this item
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Explore Campsites & Hiking Areas'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search bar + Filter button row
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search here...',
//                       prefixIcon: const Icon(Icons.search),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 20,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                     onSubmitted: (value) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: _onFilterPressed,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text('Filter'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Categories horizontal filter chips with colors and icons
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   final isSelected = selectedCategories.contains(category);
//                   final chipColor =
//                       categoryColors[category] ?? Colors.grey.shade300;
//                   final chipIcon = categoryIcons[category] ?? Icons.category;

//                   return FilterChip(
//                     label: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           chipIcon,
//                           color: isSelected ? Colors.white : chipColor,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(category),
//                       ],
//                     ),
//                     selected: isSelected,
//                     onSelected:
//                         (selected) => _onCategorySelected(selected, category),
//                     selectedColor: chipColor,
//                     backgroundColor: chipColor.withOpacity(0.3),
//                     checkmarkColor: Colors.white,
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.white : Colors.black,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Most Famous Section Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Most Famous',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // Famous hiking/campsite list (scrollable)
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildListTile(
//                     'Knuckles Range',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1529612700005-0329134a4585?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1531184277877-59a88f8b3dbd?auto=format&fit=crop&w=80&q=80',
//                   ),
//                   _buildListTile(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=80&q=80',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }
// }
//-----------------------------------//
