import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/item/item_firestore_service.dart';
import 'package:hiking_app/domain/models/item/gear_item.dart'; // Assuming your Item model is here, or adjust to 'item.dart'
import 'package:hiking_app/presentation/screens/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Keep if you use Firebase Auth directly here
import 'package:hiking_app/presentation/widgets/item/quantity_selector.dart';

class GearItemDetailScreen extends StatefulWidget {
  final Item item;

  const GearItemDetailScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<GearItemDetailScreen> createState() => _GearItemDetailScreenState();
}

class _GearItemDetailScreenState extends State<GearItemDetailScreen> {
  int _quantity = 1;
  int _rentalDays = 1;
  DateTime _selectedDate = DateTime.now();

  User? get currentUser => FirebaseAuth.instance.currentUser;
  final ItemFirestoreService _firestoreService =
      ItemFirestoreService(); // Instantiate the service

  // Determine the main image URL to display
  // Use the first image from the 'image' list, or a placeholder if the list is empty.
  String get _mainImageUrl {
    String selectedUrl;
    if (widget.item.image.isNotEmpty) {
      selectedUrl = widget.item.image[0];
      print(
          'DEBUG: ItemPage - Main Image URL from widget.item.image[0]: $selectedUrl');
    } else {
      selectedUrl =
          'https://via.placeholder.com/400x300/CCCCCC/000000?text=No+Image';
      print(
          'DEBUG: ItemPage - Main Image URL (default placeholder): $selectedUrl');
    }
    return selectedUrl;
  }

  @override
  void initState() {
    super.initState();
    // Initialize quantity based on available quantity if needed, or keep at 1
    // _quantity = widget.item.availableQty > 0 ? 1 : 0;
  }

  Future<void> _addToCart() async {
    final String? userId = currentUser?.uid; // Get the user's UID

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart.')),
      );
      return;
    }

    if (_quantity == 0 || _rentalDays == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Quantity and rental days must be greater than 0.')),
      );
      return;
    }

    try {
      // Call the service method
      await _firestoreService.addItemToCart(
        userId: userId,
        itemId: widget.item.id,
        itemName: widget.item.name,
        // FIX: Pass the first image URL from the list, or a placeholder if no images
        itemImageUrl: _mainImageUrl, // Use the derived main image URL
        itemRentPricePerDay: widget.item.rentPricePerDay,
        quantity: _quantity,
        rentalDays: _rentalDays,
        startDate: _selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.item.name} added to cart!')),
      );

      // Optionally, refresh item data after adding to cart to show updated available quantity
      // This would require fetching the item again, or passing a callback from the previous screen
      // For now, the quantity logic in the UI already accounts for the initial available quantity.
      // In a more robust app, you might want to re-fetch the item here to reflect the new available_qty.
    } catch (e) {
      print('Error adding to cart from UI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add to cart: ${e.toString().split("Exception: ").last}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Item item = widget.item; // Get the item from the widget

    final double totalPrice = item.rentPricePerDay * _rentalDays * _quantity;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                _mainImageUrl, // Use the derived main image URL
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print(
                      'DEBUG: ItemPage - Main image loading error for URL: $_mainImageUrl - Error: $error');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                        Text(
                          'Image not available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // OPTIONAL: Display all images as a horizontal scrollable list
            if (item.image.length >
                1) // Only show if there's more than one image
              SizedBox(
                height: 100, // Height for the horizontal thumbnail row
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.image.length,
                  itemBuilder: (context, index) {
                    final String thumbnailUrl = item.image[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Optional: Implement logic to change the main image displayed
                          // based on the selected thumbnail, if this were a stateful widget
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            thumbnailUrl, // Display each image from the list
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'DEBUG: ItemPage - Thumbnail image loading error for URL: $thumbnailUrl - Error: $error');
                              return const Icon(Icons.error_outline, size: 40);
                            },
                          ),
                        ),
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
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Color : ${item.color}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < item.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(width: 4),
                      Text('${item.rating.toStringAsFixed(1)} Ratings'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      QuantitySelector(
                        quantity: _quantity,
                        onDecrement: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                        onIncrement: () {
                          setState(() {
                            if (_quantity <
                                item.availableQty) // Use item.availableQty
                              _quantity++;
                            else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Maximum available quantity reached!',
                                  ),
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${item.availableQty} Units Available', // Use item.availableQty
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
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
                        if (item.specs.isNotEmpty) ...[
                          ...item.specs.entries.map((entry) {
                            String label = _capitalize(
                              entry.key.replaceAll('_', ' '),
                            );
                            String value = entry.value.toString();
                            if (entry.key == 'waterproof' &&
                                entry.value is bool) {
                              value = entry.value ? 'Yes' : 'No';
                            }
                            return _buildSpecificationRow(label, value);
                          }).toList(),
                        ],
                        const SizedBox(height: 8),
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
                                  'Rs.${item.rentPricePerDay.toStringAsFixed(2)}',
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
                            const Text(
                              'How many Days',
                              style: TextStyle(fontSize: 16),
                            ),
                            QuantitySelector(
                              quantity: _rentalDays,
                              onDecrement: () {
                                setState(() {
                                  if (_rentalDays > 1) _rentalDays--;
                                });
                              },
                              onIncrement: () {
                                setState(() {
                                  _rentalDays++;
                                });
                              },
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Add to Cart',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle check out now - You might want to navigate to a checkout screen
                        // and pass the selected item details.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Checkout functionality coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Check Out Now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : Icons.star_border,
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
