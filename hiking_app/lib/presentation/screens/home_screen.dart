import 'package:flutter/material.dart';
import 'package:hiking_app/presentation/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePageContent(),
    Center(child: Text('Search Page')),
    Center(child: Text('Favorites Page')),
    Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final categoryIcons = [
    {'icon': Icons.backpack, 'label': 'Backpacks'},
    {'icon': Icons.cast, 'label': 'Tents'},
    {'icon': Icons.directions_bike, 'label': 'Bikes'},
    {'icon': Icons.local_fire_department, 'label': 'Cooking'},
    {'icon': Icons.camera_alt, 'label': 'Camera'},
  ];

  final popularItems = [
    {
      'name': 'Outdoor Travel Bag',
      'price': 'LKR 1000',
      'img': 'assets/images/bag.jpeg',
    },
    {
      'name': 'Camping Tent',
      'price': 'LKR 1500',
      'img': 'assets/images/tent.jpeg',
    },
    {
      'name': 'Camping Tent',
      'price': 'LKR 1500',
      'img': 'assets/images/sleep_bag.jpeg',
    },
  ];

  final recommendedItems = [
    {
      'name': 'Outdoor Travel Bag',
      'price': 'LKR 1000',
      'img': 'assets/images/bag.jpeg',
    },
    {
      'name': 'Camping Tent',
      'price': 'LKR 1500',
      'img': 'assets/images/tent.jpeg',
    },
    {
      'name': 'Camping Tent',
      'price': 'LKR 1500',
      'img': 'assets/images/sleep_bag.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar

            // Category Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: categoryIcons.map((cat) {
                  return Column(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color.fromARGB(255, 226, 227, 226),
                        child: Icon(cat['icon'] as IconData,
                            color: const Color.fromARGB(255, 45, 46, 45)),
                      ),
                      SizedBox(height: 4),
                      Text(cat['label'] as String,
                          style: TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),

            // Discount Banner
            DiscountBanner(),

            SizedBox(height: 20),
            // Popular Items
            SectionTitle(title: "Popular Items"),
            ItemList(items: popularItems),

            // Recommended
            SectionTitle(title: "Recommend for you"),
            ItemList(items: recommendedItems),

            // Customer Feedback
            SectionTitle(title: "Customer Feedback"),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  FeedbackCard(
                    imagePath: 'assets/images/john.jpeg',
                    feedback: "Awesome service & quality gear.",
                  ),
                  FeedbackCard(
                    imagePath: 'assets/images/sarah.jpeg',
                    feedback: "Fast delivery and friendly support.",
                  ),
                  FeedbackCard(
                    imagePath: 'assets/images/sarah.jpeg',
                    feedback: "Fast delivery and friendly support.",
                  ),
                  // Add more FeedbackCards as needed
                ],
              ),
            ),

            // Map Section
            SectionTitle(title: "Find Shops"),
            Container(
              margin: EdgeInsets.all(12),
              height: 200,
              color: Colors.grey[300],
              child: Center(
                  child: Icon(Icons.map, size: 60, color: Colors.grey[600])),
            ),
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

class FeedbackCard extends StatelessWidget {
  final String imagePath;
  final String feedback;

  const FeedbackCard({required this.imagePath, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: EdgeInsets.only(right: 12),
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
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
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
