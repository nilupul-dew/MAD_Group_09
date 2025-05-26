// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hiking_app/presentation/viewmodels/place_viewmodel.dart';

// import 'package:hiking_app/domain/models/place_model.dart';

// class ExploreScreen extends StatefulWidget {
//   const ExploreScreen({Key? key}) : super(key: key);

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   List<String> selectedCategories = [];
//   final TextEditingController _searchController = TextEditingController();

//   final List<String> categories = [
//     'Mountains',
//     'Waterfalls',
//     'Lakes',
//     'Beaches',
//     'Forests',
//   ];

//   final Map<String, Color> categoryColors = {
//     'Mountains': Color.fromARGB(255, 168, 85, 18),
//     'Waterfalls': Color.fromARGB(255, 136, 171, 216),
//     'Lakes': Color.fromARGB(255, 123, 156, 124),
//     'Beaches': Color.fromARGB(255, 151, 125, 99),
//     'Forests': Color.fromARGB(255, 32, 100, 95),
//   };

//   final Map<String, IconData> categoryIcons = {
//     'Mountains': Icons.terrain,
//     'Waterfalls': Icons.waterfall_chart,
//     'Lakes': Icons.water,
//     'Beaches': Icons.beach_access,
//     'Forests': Icons.park,
//   };

//   void _onSearch(String query) {
//     Provider.of<PlaceViewModel>(
//       context,
//       listen: false,
//     ).updateSearchQuery(query);
//   }

//   void _onCategorySelected(bool selected, String category) {
//     setState(() {
//       if (selected) {
//         selectedCategories.add(category);
//       } else {
//         selectedCategories.remove(category);
//       }
//     });

//     final model = Provider.of<PlaceViewModel>(context, listen: false);
//     model.updateSelectedCategories(selectedCategories); // ✅ Send full list
//   }

//   Widget _buildCardItem(PlaceModel place) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       height: 100,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         image: DecorationImage(
//           image: NetworkImage(place.imageUrl),
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
//           // TODO: Navigate to detail screen
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 70, top: 13),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             place.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(blurRadius: 5, color: Colors.black),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             place.locationName,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 15,
//                               shadows: [
//                                 Shadow(blurRadius: 5, color: Colors.black),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.10),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_forward_ios,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 40,
//                   horizontal: 20,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.40),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.elliptical(7, 5),
//                   ),
//                 ),
//                 child: Icon(
//                   place.type == 'Hiking Area'
//                       ? Icons.directions_walk
//                       : FontAwesomeIcons.campground,
//                   size: 22,
//                   color: const Color.fromARGB(221, 253, 253, 253),
//                 ),
//               ),
//             ),
//           ],
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
//         centerTitle: true,
//       ),
//       body: Consumer<PlaceViewModel>(
//         builder: (context, viewModel, _) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search here...',
//                           prefixIcon: const Icon(Icons.search),
//                           filled: true,
//                           fillColor: Colors.white,
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 0,
//                             horizontal: 20,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(25),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onSubmitted: _onSearch,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton.icon(
//                       onPressed: () => _onSearch(_searchController.text),
//                       icon: const Icon(Icons.filter_list),
//                       label: const Text('Filter'),
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 1,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   height: 75,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: categories.length,
//                     separatorBuilder:
//                         (context, index) => const SizedBox(width: 8),
//                     itemBuilder: (context, index) {
//                       final category = categories[index];
//                       final isSelected = viewModel.selectedCategories.contains(
//                         category,
//                       );
//                       final chipColor =
//                           categoryColors[category] ?? Colors.grey.shade300;
//                       final chipIcon =
//                           categoryIcons[category] ?? Icons.category;

//                       return FilterChip(
//                         label: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               chipIcon,
//                               color: isSelected ? Colors.white : chipColor,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(category),
//                           ],
//                         ),
//                         selected: isSelected,
//                         onSelected:
//                             (selected) =>
//                                 _onCategorySelected(selected, category),
//                         selectedColor: chipColor,
//                         backgroundColor: chipColor.withOpacity(0.3),
//                         checkmarkColor: Colors.white,
//                         labelStyle: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     'Most Famous',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Expanded(
//                   child:
//                       viewModel.isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : ListView.builder(
//                             itemCount: viewModel.places.length,
//                             itemBuilder: (context, index) {
//                               final place = viewModel.places[index];
//                               return _buildCardItem(place);
//                             },
//                           ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//---------------Above correct-------------------//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking_app/presentation/viewmodels/place_viewmodel.dart';
import 'package:hiking_app/domain/models/place_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<String> selectedCategories = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Mountains',
    'Waterfalls',
    'Lakes',
    'Beaches',
    'Forests',
  ];

  final Map<String, Color> categoryColors = {
    'Mountains': const Color.fromARGB(255, 168, 85, 18),
    'Waterfalls': const Color.fromARGB(255, 136, 171, 216),
    'Lakes': const Color.fromARGB(255, 123, 156, 124),
    'Beaches': const Color.fromARGB(255, 151, 125, 99),
    'Forests': const Color.fromARGB(255, 32, 100, 95),
  };

  final Map<String, IconData> categoryIcons = {
    'Mountains': Icons.terrain,
    'Waterfalls': Icons.waterfall_chart,
    'Lakes': Icons.water,
    'Beaches': Icons.beach_access,
    'Forests': Icons.park,
  };

  void _onSearch(String query) {
    final model = Provider.of<PlaceViewModel>(context, listen: false);
    model.updateSearchQuery(query);
    if (query.isNotEmpty) {
      model.addSearchTerm(query);
    }
  }

  void _onCategorySelected(bool selected, String category) {
    setState(() {
      if (selected) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });

    final model = Provider.of<PlaceViewModel>(context, listen: false);
    model.updateSelectedCategories(selectedCategories); // Send full list
  }

  Widget _buildCardItem(PlaceModel place) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(place.imageUrl),
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
          // TODO: Navigate to detail screen
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
                      padding: const EdgeInsets.only(left: 70, top: 13),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
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
                            place.locationName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
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
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.40),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.elliptical(7, 5),
                  ),
                ),
                child: Icon(
                  place.type == 'Hiking Area'
                      ? Icons.directions_walk
                      : FontAwesomeIcons.campground,
                  size: 22,
                  color: const Color.fromARGB(221, 253, 253, 253),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(PlaceViewModel viewModel) {
    final query = _searchController.text.toLowerCase();
    final suggestions =
        viewModel.searchHistory
            .where((term) => term.toLowerCase().startsWith(query))
            .toList();

    if (query.isEmpty || suggestions.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion),
          leading: const Icon(Icons.history),
          onTap: () {
            _searchController.text = suggestion;
            _onSearch(suggestion);
            FocusScope.of(context).unfocus();
          },
        );
      },
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
      body: Consumer<PlaceViewModel>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch('');
                                    },
                                  )
                                  : null,
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
                        onChanged: _onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),

                // Suggestions
                _buildSuggestions(viewModel),

                const SizedBox(height: 10),

                // Category chips row
                SizedBox(
                  height: 75,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = viewModel.selectedCategories.contains(
                        category,
                      );
                      final chipColor =
                          categoryColors[category] ?? Colors.grey.shade300;
                      final chipIcon =
                          categoryIcons[category] ?? Icons.category;

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
                            (selected) =>
                                _onCategorySelected(selected, category),
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

                const SizedBox(height: 12),

                // Hiking & Campsite filter chips row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      label: Row(
                        children: const [
                          Icon(Icons.directions_walk, size: 20),
                          SizedBox(width: 6),
                          Text('Hiking Area'),
                        ],
                      ),
                      selected: viewModel.selectedCategories.contains(
                        'Hiking Area',
                      ),
                      onSelected:
                          (selected) =>
                              _onCategorySelected(selected, 'Hiking Area'),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: Row(
                        children: const [
                          Icon(FontAwesomeIcons.campground, size: 20),
                          SizedBox(width: 6),
                          Text('Campsite'),
                        ],
                      ),
                      selected: viewModel.selectedCategories.contains(
                        'Campsite',
                      ),
                      onSelected:
                          (selected) =>
                              _onCategorySelected(selected, 'Campsite'),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Most Famous Title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Most Famous',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                const SizedBox(height: 25),

                // Places list or loading spinner
                Expanded(
                  child:
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            itemCount: viewModel.places.length,
                            itemBuilder: (context, index) {
                              final place = viewModel.places[index];
                              return _buildCardItem(place);
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//-----------------------------------------------//
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

//   // Updated modern card style with small white badge icon for type
//   Widget _buildCardItem(
//     String title,
//     String subtitle,
//     String imageUrl,
//     String type,
//   ) {
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
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                         left: 70,
//                         top: 13,
//                       ), // Padding for badge space
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             title,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               shadows: [
//                                 Shadow(blurRadius: 5, color: Colors.black),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             subtitle,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 15,
//                               shadows: [
//                                 Shadow(blurRadius: 5, color: Colors.black),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Transform.translate(
//                     offset: const Offset(
//                       0,
//                       -5,
//                     ), // Adjust x,y to position precisely
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 0),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 10,
//                           horizontal: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.10),
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: const Icon(
//                           Icons.arrow_forward_ios,
//                           color: Color.fromARGB(221, 252, 252, 252),
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Small white badge with type icon at top-left
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 40,
//                   horizontal: 20,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.40),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.elliptical(7, 5),
//                   ),
//                 ),
//                 child: Icon(
//                   type == 'Hiking Area'
//                       ? Icons.directions_walk
//                       : FontAwesomeIcons
//                           .campground, // Changed to default camping icon
//                   size: 22,
//                   color: const Color.fromARGB(221, 2, 43, 16),
//                 ),
//               ),
//             ),
//           ],
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
//         centerTitle: true,
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
//                     'Hiking Area',
//                   ),
//                   _buildCardItem(
//                     'Ella Rock',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=600&q=80',
//                     'Hiking Area',
//                   ),
//                   _buildCardItem(
//                     'Adam’s Peak',
//                     'Sri Lanka',
//                     'https://media.gettyimages.com/id/1245433305/photo/a-night-view-of-sri-pada-on-january-9-in-maskeliya-sri-lanka-adams-peak-or-the-sri-pada-is-an.jpg?s=612x612&w=0&k=20&c=2hxaln8sJNzaRSIQe2Ra0FZ4dWZ-UJY7GT-ib4A9iQ8=',
//                     'Hiking Area',
//                   ),
//                   _buildCardItem(
//                     'Pidurangala Rock',
//                     'Sri Lanka',
//                     'https://media.gettyimages.com/id/992296464/photo/sri-lankas-world-heritage-site-sigiriya-or-sihigiriya.jpg?s=612x612&w=0&k=20&c=NHTizDy5Ct3B_ywlv06PADwyqdvpSJyFciTjHLtiwsg=',
//                     'Campsite',
//                   ),
//                   _buildCardItem(
//                     'Horton Plains',
//                     'Sri Lanka',
//                     'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
//                     'Campsite',
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
