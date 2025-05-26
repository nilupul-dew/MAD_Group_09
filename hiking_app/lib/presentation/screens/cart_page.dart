// cart_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Keep if you plan to use FirebaseAuth later
import 'package:hiking_app/presentation/screens/search_page.dart';
import 'package:hiking_app/presentation/widgets/quantity_selector.dart'; // Import the new widget
import 'package:intl/intl.dart'; // For date formatting // Assuming you have a HomePage for redirection

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final String _testUserId =
      'temp_test_user_id_001'; // Make sure this matches item_page.dart

  // Uncomment this when you implement real authentication
  // User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // String? userId = currentUser?.uid; // Use this when auth is ready
    String userId = _testUserId; // For testing with hardcoded ID

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(child: Text('Please log in to view your cart.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('My cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('carts')
                .doc(userId)
                .collection('items')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your cart is empty.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ), // Redirect to HomePage
                        (Route<dynamic> route) =>
                            false, // Remove all routes below
                      );
                    },
                    icon: const Icon(Icons.explore, color: Colors.white),
                    label: const Text(
                      'Continue Exploring',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0772C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          List<DocumentSnapshot> cartItems = snapshot.data!.docs;
          double totalProductPrice = 0.0;
          double totalDiscount = 0.0;

          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            double pricePerDay =
                (data['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;
            int quantity = (data['quantity'] as int?) ?? 1;
            int rentalDays = (data['rental_days'] as int?) ?? 1;
            totalProductPrice += (pricePerDay * quantity * rentalDays);
          }

          if (totalProductPrice > 0) {
            totalDiscount = 500.0; // Example discount
          }

          double orderTotal = totalProductPrice - totalDiscount;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    var data = item.data() as Map<String, dynamic>;

                    // Get both the cart document ID and the original gear item ID
                    String cartItemId =
                        item.id; // This is the ID of the document in 'carts/userId/items'
                    String gearItemId =
                        data['item_id'] ??
                        ''; // This is the ID of the original item in 'gear_items'

                    String itemName = data['name'] ?? 'N/A';
                    String imageUrl =
                        data['image_url'] ?? 'https://via.placeholder.com/150';
                    double rentPricePerDay =
                        (data['rent_price_per_day'] as num?)?.toDouble() ?? 0.0;
                    int quantity = (data['quantity'] as int?) ?? 1;
                    int rentalDays = (data['rental_days'] as int?) ?? 1;
                    DateTime startDate =
                        (data['start_date'] as Timestamp)
                            .toDate(); // Assuming start_date is a Timestamp

                    double itemTotalPrice =
                        rentPricePerDay * quantity * rentalDays;

                    return _buildCartItemCard(
                      context,
                      cartItemId: cartItemId, // Pass the cart item doc ID
                      gearItemId: gearItemId, // Pass the original gear item ID
                      itemName: itemName,
                      imageUrl: imageUrl,
                      price: rentPricePerDay, // This is price per day
                      quantity: quantity, // Current quantity in cart
                      rentalDays: rentalDays,
                      itemTotalPrice:
                          itemTotalPrice, // Calculated total for this specific cart item
                      startDate: startDate, // Pass the start date
                    );
                  },
                ),
              ),
              _buildPriceDetailsCard(
                totalProductPrice,
                totalDiscount,
                orderTotal,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Check Out button pressed!');
                          // TODO: Implement checkout logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0772C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Check Out',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10), // Space between buttons
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context, {
    required String cartItemId, // ID of the document in 'carts/userId/items'
    required String gearItemId, // ID of the document in 'gear_items'
    required String itemName,
    required String imageUrl,
    required double price, // This is rentPricePerDay
    required int quantity, // Current quantity in cart
    required int rentalDays,
    required double itemTotalPrice,
    required DateTime startDate, // Add startDate here
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs.${itemTotalPrice.toStringAsFixed(2)}', // Display total for this item
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    '(${price.toStringAsFixed(2)}/day)', // Display price per day as well
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Use your custom QuantitySelector here
                      QuantitySelector(
                        quantity: quantity,
                        // Pass both cartItemId and gearItemId to update function
                        onDecrement:
                            () => _updateQuantity(
                              cartItemId,
                              gearItemId,
                              quantity - 1,
                              itemName,
                            ),
                        onIncrement:
                            () => _updateQuantity(
                              cartItemId,
                              gearItemId,
                              quantity + 1,
                              itemName,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'for $rentalDays days from ${DateFormat('MMM d').format(startDate)}', // Display rental days and start date
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              // Pass both cartItemId and gearItemId to remove function
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed:
                  () => _removeItemFromCart(
                    cartItemId,
                    gearItemId,
                    quantity,
                  ), // Pass current quantity for stock return
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsCard(
    double totalProductPrice,
    double totalDiscount,
    double orderTotal,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              'Total Product Price',
              'Rs.${totalProductPrice.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Total Discount',
              '- Rs.${totalDiscount.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
            const Divider(height: 24, thickness: 1),
            _buildPriceRow(
              'Order Total',
              'Rs.${orderTotal.toStringAsFixed(2)}',
              isBold: true,
              valueColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // --- MODIFIED _updateQuantity function ---
  Future<void> _updateQuantity(
    String cartItemId,
    String gearItemId,
    int newQuantity,
    String itemName,
  ) async {
    final String userId = _testUserId;

    if (newQuantity < 1) {
      // If new quantity is less than 1, remove the item
      _removeItemFromCart(
        cartItemId,
        gearItemId,
        1,
      ); // Pass 1 to remove the last item and return its stock
      return;
    }

    try {
      final cartItemDocRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItemId);
      final gearItemDocRef = FirebaseFirestore.instance
          .collection('gear_items')
          .doc(gearItemId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot latestCartItemSnapshot = await transaction.get(
          cartItemDocRef,
        );
        DocumentSnapshot latestGearItemSnapshot = await transaction.get(
          gearItemDocRef,
        );

        if (!latestCartItemSnapshot.exists) {
          throw Exception(
            "Cart item not found in database during transaction.",
          );
        }
        if (!latestGearItemSnapshot.exists) {
          // If the original gear item doesn't exist, we can't update its stock.
          // Still update cart quantity if needed, but log a warning.
          print(
            "Warning: Original gear item $gearItemId not found for stock adjustment.",
          );
          // Proceed to update cart quantity without stock adjustment
          transaction.update(cartItemDocRef, {'quantity': newQuantity});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quantity updated for item: $itemName, but stock unavailable.',
              ),
            ),
          );
          return;
        }

        int currentQuantityInCart =
            (latestCartItemSnapshot.data()
                as Map<String, dynamic>)['quantity'] ??
            0;
        int currentAvailableQtyInGearItem =
            (latestGearItemSnapshot.data()
                as Map<String, dynamic>)['available_qty'] ??
            0;

        int quantityChange = newQuantity - currentQuantityInCart;

        if (quantityChange > 0) {
          // Increasing quantity
          if (currentAvailableQtyInGearItem < quantityChange) {
            throw Exception(
              "Not enough available stock to add more of $itemName.",
            );
          }
          // Decrement available_qty in gear_items
          transaction.update(gearItemDocRef, {
            'available_qty': FieldValue.increment(-quantityChange),
          });
        } else if (quantityChange < 0) {
          // Decreasing quantity
          // Increment available_qty in gear_items
          transaction.update(gearItemDocRef, {
            'available_qty': FieldValue.increment(-quantityChange),
          }); // -change makes it +
        }
        // Update the quantity in the cart item
        transaction.update(cartItemDocRef, {'quantity': newQuantity});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity updated for item: $itemName')),
      );
    } catch (e) {
      print('Error updating quantity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update quantity: ${e.toString().split("Exception: ").last}',
          ),
        ),
      );
    }
  }

  // --- MODIFIED _removeItemFromCart function ---
  Future<void> _removeItemFromCart(
    String cartItemId,
    String gearItemId,
    int quantityInCart,
  ) async {
    final String userId = _testUserId;

    try {
      final cartItemDocRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItemId);

      final gearItemDocRef = FirebaseFirestore.instance
          .collection('gear_items')
          .doc(gearItemId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot cartSnapshot = await transaction.get(cartItemDocRef);
        DocumentSnapshot gearItemSnapshot = await transaction.get(
          gearItemDocRef,
        );

        if (!cartSnapshot.exists) {
          print(
            'Warning: Cart item $cartItemId not found during removal (it might have been removed already).',
          );
          return; // Item already gone, nothing to do.
        }

        // Only try to return stock if the original gear item exists
        if (gearItemSnapshot.exists) {
          // Return the quantity that was in the cart item back to the main stock
          transaction.update(gearItemDocRef, {
            'available_qty': FieldValue.increment(quantityInCart),
          });
          print(
            'Stock returned for item $gearItemId. Returned $quantityInCart units.',
          );
        } else {
          print(
            'Warning: Original gear item $gearItemId not found for stock return during cart removal. Cart item still removed.',
          );
        }

        // Always delete the cart item
        transaction.delete(cartItemDocRef);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart!')));
      // No explicit refresh needed for StreamBuilder, it will rebuild automatically
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from cart: ${e.toString()}')),
      );
    }
  }
}
