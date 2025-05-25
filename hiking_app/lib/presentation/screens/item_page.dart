import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Firebase Auth - Keep this for later uncommenting

class GearItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const GearItemDetailScreen({Key? key, required this.itemData})
      : super(key: key);

  @override
  State<GearItemDetailScreen> createState() => _GearItemDetailScreenState();
}

class _GearItemDetailScreenState extends State<GearItemDetailScreen> {
  int _quantity = 1;
  int _rentalDays = 1;
  DateTime _selectedDate = DateTime.now();

  // Uncomment this line and use it for user ID when authentication is ready:
  // User? get currentUser => FirebaseAuth.instance.currentUser;

  // FOR TESTING ONLY: Hardcoded test user ID
  // When authentication is implemented, remove this line and uncomment the currentUser getter above.
  final String _testUserId = 'temp_test_user_id_001'; // You can change this ID

  // Function to add item to cart in Firebase
  Future<void> _addToCart() async {
    // In a real app, you'd use the authenticated user's ID:
    // final String? userId = currentUser?.uid;

    // For now, using the hardcoded test user ID:
    final String userId = _testUserId;

    // In a real app, you would add a check like this:
    // if (userId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please log in to add items to cart.')),
    //   );
    //   return;
    // }

    try {
      final String itemId = widget.itemData['id'] ?? 'unknown_item_id'; // Assuming 'id' is available in itemData
      final String itemName = widget.itemData['name'] ?? 'N/A';
      final String itemImageUrl = widget.itemData['image'] ?? 'https://via.placeholder.com/150';
      final double itemRentPricePerDay = (widget.itemData['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;

      // Reference to the user's cart items subcollection
      final cartItemsRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId) // Use the obtained userId (test or authenticated)
          .collection('items');

      // Create a map of the item data to add to Firestore
      final Map<String, dynamic> cartItemData = {
        'item_id': itemId, // Link to the original item document
        'name': itemName,
        'image_url': itemImageUrl,
        'rent_price_per_day': itemRentPricePerDay,
        'quantity': _quantity,
        'rental_days': _rentalDays,
        'start_date': Timestamp.fromDate(_selectedDate), // Store as Firestore Timestamp
        'added_at': FieldValue.serverTimestamp(), // Timestamp when item was added
      };

      // Add the item to the user's cart. Firestore will auto-generate an ID for this cart item.
      await cartItemsRef.add(cartItemData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemName added to cart for user: $userId!')),
      );

      // Optionally, navigate to cart page or clear selections
      // Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));

    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.itemData['name'] ?? 'N/A';
    final double rating = (widget.itemData['rating'] as num?)?.toDouble() ?? 0.0;
    final String color = widget.itemData['color'] ?? 'N/A';
    final String imageUrl = widget.itemData['image'] ?? 'https://via.placeholder.com/400x300';
    final double rentPricePerDay = (widget.itemData['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;
    final int availableQuantity = widget.itemData['available_qty'] ?? 0;

    final Map<String, dynamic> specs = widget.itemData['specs'] ?? {};
    final double totalPrice = rentPricePerDay * _rentalDays * _quantity;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Product'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                        Text('Image not available', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Color : $color',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 4),
                      Text('${rating.toStringAsFixed(1)} Ratings'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () {
                                setState(() {
                                  if (_quantity < availableQuantity) _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('$availableQuantity Units Available',
                      style: const TextStyle(color: Colors.green, fontSize: 14)),
                  const SizedBox(height: 16),

                  // Specifications Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Specifications'),
                        const SizedBox(height: 8),
                        if (specs.isNotEmpty) ...[
                          ...specs.entries.map((entry) {
                            String label = _capitalize(entry.key.replaceAll('_', ' '));
                            String value = entry.value.toString();
                            if (entry.key == 'waterproof' && entry.value is bool) {
                              value = entry.value ? 'Yes' : 'No';
                            }
                            return _buildSpecificationRow(label, value);
                          }).toList(),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See more',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rent Details Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Rent Details'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rs.${rentPricePerDay.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text('per day'),
                              ],
                            ),
                            
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('How many Days', style: TextStyle(fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (_rentalDays > 1) _rentalDays--;
                                      });
                                    },
                                  ),
                                  Text(
                                    '$_rentalDays',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _rentalDays++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'From ${DateFormat('yyyy/MM/dd').format(_selectedDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null && picked != _selectedDate) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: const Text(
                                'Customize Date',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs.${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _quantity = 1;
                                    _rentalDays = 1;
                                    _selectedDate = DateTime.now();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[400]!),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addToCart, // Call the _addToCart function
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle check out now
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Check Out Now', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Reviews'),
                  const SizedBox(height: 8),
                  _buildUserReview(
                    'Mr.Elapatha',
                    'I always love shopping here. I appreciate the hard work your team has put into delivering awesome service. I look forward to future updates.',
                    4.5,
                  ),
                  _buildUserReview(
                    'Mr.Elapatha',
                    'I always love shopping here. I appreciate the hard work your team has put into delivering awesome service. I look forward to future updates.',
                    4.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildUserReview(String userName, String reviewText, double rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reviewText),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}