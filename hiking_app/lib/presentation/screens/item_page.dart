import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiking_app/presentation/widgets/quantity_selector.dart'; // Import your QuantitySelector

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

  final String _testUserId = 'temp_test_user_id_001';

  Future<void> _addToCart() async {
    final String userId = _testUserId;

    try {
      final String itemId = widget.itemData['id'] ?? 'unknown_item_id';
      final String itemName = widget.itemData['name'] ?? 'N/A';
      final String itemImageUrl =
          widget.itemData['image'] ?? 'https://via.placeholder.com/150';
      final double itemRentPricePerDay =
          (widget.itemData['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;
      final int originalAvailableQty =
          widget.itemData['available_qty'] ??
          0; // Get original available quantity

      // --- Start Transaction for adding to cart and updating stock ---
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the latest snapshot of the gear item
        final gearItemDocRef = FirebaseFirestore.instance
            .collection('gear_items')
            .doc(itemId);
        DocumentSnapshot latestGearItemSnapshot = await transaction.get(
          gearItemDocRef,
        );

        if (!latestGearItemSnapshot.exists) {
          throw Exception("Item not found in inventory. Cannot add to cart.");
        }

        int currentAvailableQtyInDb =
            (latestGearItemSnapshot.data()
                as Map<String, dynamic>)['available_qty'] ??
            0;

        if (currentAvailableQtyInDb < _quantity) {
          throw Exception(
            "Not enough stock available for $itemName. Only $currentAvailableQtyInDb units remaining.",
          );
        }

        // Decrement the available quantity in the gear_items collection
        transaction.update(gearItemDocRef, {
          'available_qty': currentAvailableQtyInDb - _quantity,
        });

        // Reference to the user's cart items subcollection
        final cartItemsRef = FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('items');

        // Check if the item already exists in the cart for the given rental period
        final existingCartItemQuery =
            await cartItemsRef
                .where('item_id', isEqualTo: itemId)
                .where(
                  'start_date',
                  isEqualTo: Timestamp.fromDate(_selectedDate),
                )
                .where('rental_days', isEqualTo: _rentalDays)
                .limit(1)
                .get();

        if (existingCartItemQuery.docs.isNotEmpty) {
          // Item already in cart with same details, update quantity
          final existingCartItemDoc = existingCartItemQuery.docs.first;
          int currentQuantityInCart =
              (existingCartItemDoc.data())['quantity'] ?? 0;
          transaction.update(existingCartItemDoc.reference, {
            'quantity': currentQuantityInCart + _quantity,
            'added_at': FieldValue.serverTimestamp(),
          });
          print('Existing cart item quantity updated for $itemName.');
        } else {
          // Item not in cart, add a new one
          final Map<String, dynamic> cartItemData = {
            'item_id': itemId,
            'name': itemName,
            'image_url': itemImageUrl,
            'rent_price_per_day': itemRentPricePerDay,
            'quantity': _quantity,
            'rental_days': _rentalDays,
            'start_date': Timestamp.fromDate(_selectedDate),
            'added_at': FieldValue.serverTimestamp(),
          };
          transaction.set(
            cartItemsRef.doc(),
            cartItemData,
          ); // Use set with auto-generated ID
          print('New cart item added for $itemName.');
        }
      });
      // --- End Transaction ---

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemName added to cart for user: $userId!')),
      );
    } catch (e) {
      print('Error adding to cart: $e');
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
    final String name = widget.itemData['name'] ?? 'N/A';
    final double rating =
        (widget.itemData['rating'] as num?)?.toDouble() ?? 0.0;
    final String color = widget.itemData['color'] ?? 'N/A';
    final String imageUrl =
        widget.itemData['image'] ?? 'https://via.placeholder.com/400x300';
    final double rentPricePerDay =
        (widget.itemData['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;
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
                            index < rating.floor()
                                ? Icons.star
                                : Icons.star_border,
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
                      // *** Use QuantitySelector for Quantity ***
                      QuantitySelector(
                        quantity: _quantity,
                        onDecrement: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                        onIncrement: () {
                          setState(() {
                            if (_quantity < availableQuantity)
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
                    '$availableQuantity Units Available',
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
                        if (specs.isNotEmpty) ...[
                          ...specs.entries.map((entry) {
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
                            const Text(
                              'How many Days',
                              style: TextStyle(fontSize: 16),
                            ),
                            // *** Use QuantitySelector for Rental Days ***
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
                                onPressed:
                                    _addToCart, // Call the _addToCart function
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
    return s
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}
