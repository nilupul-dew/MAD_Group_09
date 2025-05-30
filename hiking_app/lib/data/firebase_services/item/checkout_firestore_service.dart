// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to add a new order to a 'orders' collection
  Future<void> addOrder({
    required String userId, // The actual user ID will be passed here
    required String selectedPaymentMethod,
    required double totalAmount,
    required List<Map<String, dynamic>>
        items, // Example: [{'name': 'Product A', 'price': 10.0, 'qty': 1}]
    String? deliveryAddress,
  }) async {
    try {
      await _db.collection('orders').add({
        'userId': userId,
        'selectedPaymentMethod': selectedPaymentMethod,
        'totalAmount': totalAmount,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'orderDate': Timestamp.now(), // Firestore timestamp
        'status': 'pending', // Initial status
      });
      print("Order added to Firestore successfully for user: $userId");
    } on FirebaseException catch (e) {
      print("Error adding order to Firestore: ${e.message}");
      rethrow; // Re-throw the error so it can be caught in the UI
    } catch (e) {
      print("An unexpected error occurred: $e");
      rethrow;
    }
  }
}
