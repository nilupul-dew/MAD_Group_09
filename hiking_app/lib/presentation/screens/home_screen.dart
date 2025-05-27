import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/widgets/bottom_nav_bar.dart';
import 'package:hiking_app/presentation/widgets/item_card.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePageContent(),
    Center(child: Text('Items')),
    Center(child: Text('Locations')),
    Center(child: Text('Community')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isChatExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],

          // Floating Chat/SOS Button with Animation
          Positioned(
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSlide(
                  offset: _isChatExpanded ? Offset(0, 0) : Offset(0, 0.5),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _isChatExpanded ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: FloatingActionButton.extended(
                      heroTag: 'chat',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Chat tapped")),
                        );
                      },
                      icon: Icon(Icons.chat),
                      label: Text('Chat'),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                AnimatedSlide(
                  offset: _isChatExpanded ? Offset(0, 0) : Offset(0, 0.5),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _isChatExpanded ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: FloatingActionButton.extended(
                      heroTag: 'sos',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("SOS tapped")),
                        );
                      },
                      icon: Icon(
                        Icons.warning,
                        color: const Color.fromARGB(255, 248, 4, 4),
                      ),
                      label: Text('SOS',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 253, 4, 4))),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'main',
                  onPressed: () {
                    setState(() {
                      _isChatExpanded = !_isChatExpanded;
                    });
                  },
                  child: Icon(_isChatExpanded ? Icons.close : Icons.message),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo1.png',
                height: 80,
              ),
              SizedBox(width: 8),
              Text(
                'RentalGear',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search camping gear...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //category
// Category Section
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categoryIcons.length,
                itemBuilder: (context, index) {
                  final item = categoryIcons[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['label']} tapped')),
                      );
                    },
                    child: Container(
                      width: 70,
                      margin: EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${item['label']} selected')),
                              );
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 30,
                                color: const Color.fromARGB(255, 2, 2, 2),
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Discount Banner
            DiscountBanner(),
            SizedBox(height: 20),
            // Popular Items
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double spacing = 16.0;
                  double cardWidth = (screenWidth - spacing) / 2;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: "Popular Items"),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/backback3.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 2, 2, 2),
                              bottomColor:
                                  const Color.fromARGB(255, 141, 142, 142),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                          SizedBox(width: spacing), // spacing between two cards
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/tent1-.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 2, 65, 100),
                              bottomColor:
                                  const Color.fromARGB(255, 80, 105, 119),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/popular'),
                          child: Text(
                            'See more',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 3, 90, 162),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

// Recommended for you
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double spacing = 16.0;
                  double cardWidth = (screenWidth - spacing * 1) / 2;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: "Recommend for you"),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: spacing,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/hammoch-.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 101, 1, 1),
                              bottomColor:
                                  const Color.fromARGB(255, 170, 123, 123),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/bag1-.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 1, 26, 152),
                              bottomColor:
                                  const Color.fromARGB(255, 133, 143, 159),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/backpack1-.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 255, 48, 227),
                              bottomColor:
                                  const Color.fromARGB(255, 254, 162, 237),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ItemCard(
                              assetImagePath: 'assets/images/sleeping_bag-.png',
                              title: 'Waterproof Outdoor Travel Backpack',
                              capacity: '40 - 50 L',
                              price: 'Rs.150.00',
                              listedBy: 'EstyBags.lk',
                              topColor: const Color.fromARGB(255, 30, 255, 9),
                              bottomColor:
                                  const Color.fromARGB(255, 131, 247, 158),
                              onTap: () => (),
                              onCartTap: () =>
                                  Navigator.pushNamed(context, '/cart'),
                              onFavoriteTap: () =>
                                  Navigator.pushNamed(context, '/wishlist'),
                              onShareTap: () =>
                                  Navigator.pushNamed(context, '/share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/recommendations'),
                          child: Text(
                            'See more',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 15, 71, 117),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Customer Feedback
            SectionTitle(title: "Customer Feedback"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FeedbackCard(
                    imagePath: 'assets/images/john.jpeg',
                    customerName: 'John Doe',
                    rating: 4,
                    feedback: 'Great service, highly recommend!',
                  ),
                  FeedbackCard(
                    imagePath: 'assets/images/sarah.jpeg',
                    customerName: 'Jane Smith',
                    rating: 5,
                    feedback: 'Amazing experience, will come back again.',
                  ),
                  FeedbackCard(
                    imagePath: 'assets/images/john.jpeg',
                    customerName: 'Alice Johnson',
                    rating: 3,
                    feedback: 'Good, but there is room for improvement.',
                  ),
                  // add more cards here...
                ],
              ),
            )
            // Map Section
            /*SectionTitle(title: "Find Shops"),
            FindShopsMap(),*/
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

//feedback
class FeedbackCard extends StatelessWidget {
  final String imagePath;
  final String feedback;
  final String customerName;
  final int rating; // 0 to 5 stars

  const FeedbackCard({
    required this.imagePath,
    required this.feedback,
    required this.customerName,
    required this.rating,
    Key? key,
  }) : super(key: key);

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating) {
          return Icon(Icons.star, color: Colors.amber, size: 18);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 12, bottom: 40),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: image + name below
          Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(height: 8),
              Text(
                customerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          SizedBox(width: 16),

          // Right side: stars + feedback text stacked vertically
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildStars(rating),
                SizedBox(height: 8),
                Text(
                  feedback,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const ItemList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageWidget(imagePath: item['img']),
                SizedBox(height: 10),
                Text(item['name'],
                    style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2),
                SizedBox(height: 4),
                Text(item['price'], style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imagePath;
  const ImageWidget({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return imagePath.startsWith('http')
        ? Image.network(imagePath,
            height: 80, width: double.infinity, fit: BoxFit.cover)
        : Image.asset(imagePath,
            height: 80, width: double.infinity, fit: BoxFit.cover);
  }
}

final categoryIcons = [
  {'icon': Icons.backpack, 'label': 'Backpacks'},
  {'icon': Icons.cast, 'label': 'Tents'},
  {'icon': Icons.directions_bike, 'label': 'Bikes'},
  {'icon': Icons.local_fire_department, 'label': 'Cooking'},
  {'icon': Icons.camera_alt, 'label': 'Camera'},
];

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 254, 211, 91),
            const Color.fromARGB(255, 251, 96, 0)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Circular badge
          Positioned(
            left: 20,
            top: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                    color: Colors.transparent,
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown.shade300,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 12,
                        child: Text(
                          "30%",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 25,
                        child: Container(
                          color: Colors.redAccent,
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            "BEST",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          color: Colors.redAccent,
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            "OFFER",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right-side content
          Positioned(
            left: 160,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "4 in 1",
                  style: TextStyle(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "DISCOUNTS",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Camping Packages.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(),
                  ),
                  onPressed: () {
                    // You can add navigation or popup here
                  },
                  child: Text(
                    "See Details",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Bottom-right validity note
          Positioned(
            bottom: 10,
            right: 20,
            child: Text(
              "Valid till 27 th of February",
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}

/*class FindShopsMap extends StatefulWidget {
  const FindShopsMap({super.key});

  @override
  State<FindShopsMap> createState() => _FindShopsMapState();
}

class _FindShopsMapState extends State<FindShopsMap> {
  late GoogleMapController mapController;

  final LatLng center = const LatLng(6.9271, 79.8612); // Colombo

  final List<Marker> _markers = [
    Marker(
      markerId: MarkerId("shop1"),
      position: LatLng(6.9271, 79.8612), // Colombo
      infoWindow: InfoWindow(title: "Shop 1", snippet: "Colombo Center"),
    ),
    Marker(
      markerId: MarkerId("shop2"),
      position: LatLng(7.2906, 80.6337), // Kandy
      infoWindow: InfoWindow(title: "Shop 2", snippet: "Kandy Branch"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      height: 250,
      child: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 7.5,
        ),
        markers: Set.from(_markers),
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
*/
