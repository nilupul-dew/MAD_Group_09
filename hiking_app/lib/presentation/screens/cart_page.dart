// lib/presentation/screens/cart_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for QuerySnapshot/DocumentSnapshot types for StreamBuilder
import 'package:firebase_auth/firebase_auth.dart'; // Keep if you plan to use FirebaseAuth later
import 'package:hiking_app/presentation/screens/search_page.dart';
import 'package:hiking_app/presentation/widgets/cart_card.dart';
import 'package:intl/intl.dart';

// Import your new service and model
import 'package:hiking_app/domain/models/cart_item.dart';
import 'package:hiking_app/data/firebase_services/cart_firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final String _testUserId =
      'temp_test_user_id_001'; // Make sure this matches item_page.dart

  // Instantiate your CartFirestoreService
  late final CartFirestoreService _cartFirestoreService;

  // Uncomment this when you implement real authentication
  // User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _cartFirestoreService = CartFirestoreService(); // Initialize the service
  }

  @override
  Widget build(BuildContext context) {
    // String? userId = currentUser?.uid; // Use this when auth is ready
    String userId = _testUserId; // For testing with hardcoded ID

    if (userId.isEmpty) {
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
      body: StreamBuilder<List<CartItem>>(
        // Now stream List<CartItem> directly
        stream: _cartFirestoreService.getCartItemsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<CartItem> cartItems = snapshot.data ?? []; // Use CartItem model

          if (cartItems.isEmpty) {
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
                          builder:
                              (context) =>
                                  const SearchScreen(), // Redirect to SearchScreen
                        ),
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

          // Calculate totals using the List<CartItem>
          double totalProductPrice = 0.0;
          for (var item in cartItems) {
            totalProductPrice +=
                (item.rentPricePerDay * item.quantity * item.rentalDays);
          }

          double totalDiscount = 0.0;
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
                    final CartItem cartItem =
                        cartItems[index]; // Use the CartItem object directly

                    return CartCard(
                      cartItemId: cartItem.cartItemId,
                      gearItemId: cartItem.gearItemId,
                      itemName: cartItem.name,
                      imageUrl: cartItem.imageUrl,
                      price: cartItem.rentPricePerDay,
                      quantity: cartItem.quantity,
                      rentalDays: cartItem.rentalDays,
                      itemTotalPrice:
                          cartItem.rentPricePerDay *
                          cartItem.quantity *
                          cartItem.rentalDays,
                      startDate: cartItem.startDate,
                      onDecrementQuantity:
                          () => _updateQuantity(
                            cartItem.cartItemId,
                            cartItem.gearItemId,
                            cartItem.quantity - 1,
                            cartItem.name,
                          ),
                      onIncrementQuantity:
                          () => _updateQuantity(
                            cartItem.cartItemId,
                            cartItem.gearItemId,
                            cartItem.quantity + 1,
                            cartItem.name,
                          ),
                      onRemoveItem:
                          () => _removeItemFromCart(
                            cartItem.cartItemId,
                            cartItem.gearItemId,
                            cartItem.quantity,
                          ),
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
                        onPressed:
                            () => _checkout(
                              cartItems,
                              orderTotal,
                            ), // Pass necessary data
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

  // --- REFACTORED _updateQuantity function to use CartFirestoreService ---
  Future<void> _updateQuantity(
    String cartItemId,
    String gearItemId,
    int newQuantity,
    String itemName,
  ) async {
    final String userId = _testUserId;
    try {
      await _cartFirestoreService.updateCartItemQuantityAndStock(
        userId,
        cartItemId,
        gearItemId,
        newQuantity,
      );
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

  // --- REFACTORED _removeItemFromCart function to use CartFirestoreService ---
  Future<void> _removeItemFromCart(
    String cartItemId,
    String gearItemId,
    int quantityInCart,
  ) async {
    final String userId = _testUserId;
    try {
      await _cartFirestoreService.removeCartItemAndReturnStock(
        userId,
        cartItemId,
        gearItemId,
        quantityInCart,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart!')));
    } catch (e) {
      print('Error removing from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from cart: ${e.toString()}')),
      );
    }
  }

  // --- NEW: _checkout function using CartFirestoreService ---
  Future<void> _checkout(List<CartItem> items, double orderTotal) async {
    final String userId = _testUserId;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Nothing to checkout!'),
        ),
      );
      return;
    }

    try {
      await _cartFirestoreService.createOrder(userId, items, orderTotal);
      await _cartFirestoreService.clearUserCartAndReturnStock(
        userId,
      ); // Clear cart after successful order
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      // Optional: Navigate to an order confirmation screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderConfirmationScreen()));
    } catch (e) {
      print('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: ${e.toString()}')),
      );
    }
  }
}
