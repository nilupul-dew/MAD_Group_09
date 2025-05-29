import 'package:flutter/material.dart';
import 'package:hiking_app/domain/models/location-models/place_model.dart';
import 'package:hiking_app/presentation/screens/app_bar.dart';
import 'package:hiking_app/presentation/screens/location-screens/place_detail_screen.dart';
import 'package:hiking_app/domain/location-viewmodels/place_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<String> selectedCategories = [];
  List<String> selectedTypes = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Mountains',
    'Waterfalls',
    'Lakes',
    'Beaches',
    'Forests',
  ];

  final Map<String, Color> categoryColors = {
    'Mountains': Color.fromARGB(255, 168, 85, 18),
    'Waterfalls': Color.fromARGB(255, 136, 171, 216),
    'Lakes': Color.fromARGB(255, 123, 156, 124),
    'Beaches': Color.fromARGB(255, 151, 125, 99),
    'Forests': Color.fromARGB(255, 32, 100, 95),
  };

  final Map<String, IconData> categoryIcons = {
    'Mountains': Icons.terrain,
    'Waterfalls': Icons.waterfall_chart,
    'Lakes': Icons.water,
    'Beaches': Icons.beach_access,
    'Forests': Icons.park,
  };

  @override
  void initState() {
    super.initState();
    // Load all places initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlaceViewModel>(context, listen: false).loadPlaces();
    });
  }

  void _onSearch(String query) {
    Provider.of<PlaceViewModel>(
      context,
      listen: false,
    ).updateSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearch('');
  }

  void _onCategorySelected(bool selected, String category) {
    setState(() {
      if (selected) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
    Provider.of<PlaceViewModel>(
      context,
      listen: false,
    ).updateSelectedCategories(selectedCategories);
  }

  void _onTypeSelected(bool selected, String type) {
    setState(() {
      if (selected) {
        selectedTypes.add(type);
      } else {
        selectedTypes.remove(type);
      }
    });
    Provider.of<PlaceViewModel>(
      context,
      listen: false,
    ).updateSelectedTypes(selectedTypes);
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
          );
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
                  borderRadius: BorderRadius.only(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text(
          'Campsites & Hiking Areas',
          style: TextStyle(color: Color.fromARGB(255, 7, 7, 7)),
        ),
      ),
      body: Consumer<PlaceViewModel>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar with clear button
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search here...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),
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
                  onChanged: (value) {
                    _onSearch(value);
                  },
                ),

                const SizedBox(height: 10),

                // Categories filter chips
                SizedBox(
                  height: 75,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
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
                        onSelected: (selected) =>
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

                const SizedBox(height: 5),

                // Type filter chips for Hiking Area and Campsite, centered
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: Row(
                          children: const [
                            Icon(FontAwesomeIcons.personHiking, size: 20),
                            SizedBox(width: 6),
                            Text('Hiking Area'),
                          ],
                        ),
                        selected: viewModel.selectedTypes.contains(
                          'Hiking Area',
                        ),
                        onSelected: (selected) =>
                            _onTypeSelected(selected, 'Hiking Area'),
                        selectedColor: const Color.fromARGB(255, 218, 188, 149),
                        backgroundColor: const Color.fromARGB(
                          255,
                          221,
                          196,
                          163,
                        ).withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: viewModel.selectedTypes.contains('Hiking Area')
                              ? Colors.white
                              : Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        label: Row(
                          children: const [
                            Icon(FontAwesomeIcons.campground, size: 20),
                            SizedBox(width: 6),
                            Text('Campsite'),
                          ],
                        ),
                        selected: viewModel.selectedTypes.contains('Campsite'),
                        onSelected: (selected) =>
                            _onTypeSelected(selected, 'Campsite'),
                        selectedColor: const Color.fromARGB(255, 218, 188, 149),
                        backgroundColor: const Color.fromARGB(
                          255,
                          221,
                          196,
                          163,
                        ).withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: viewModel.selectedTypes.contains('Campsite')
                              ? Colors.white
                              : Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Most Famous',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: viewModel.isLoading
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
