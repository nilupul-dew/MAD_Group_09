// lib/firebase_services/cart_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/domain/models/cart_item.dart'; // Import your CartItem model

class CartFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get a reference to the user's cart items collection
  CollectionReference<Map<String, dynamic>> _userCartItemsCollection(String userId) {
    return _firestore.collection('carts').doc(userId).collection('items');
  }

  // --- READ Operations ---

  /// Returns a stream of CartItem objects for a given user.
  Stream<List<CartItem>> getCartItemsStream(String userId) {
    return _userCartItemsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
    });
  }

  // --- WRITE/UPDATE/DELETE Operations ---

  /// Updates the quantity of an existing cart item and adjusts inventory.
  /// This operation is performed as a Firestore Transaction to ensure atomicity.
  Future<void> updateCartItemQuantityAndStock(
      String userId, String cartItemId, String gearItemId, int newQuantity) async {
    // If new quantity is less than 1, implicitly remove the item
    if (newQuantity < 1) {
      await removeCartItemAndReturnStock(userId, cartItemId, gearItemId, 1); // Assuming 1 unit is being "removed"
      return;
    }

    final cartItemDocRef = _userCartItemsCollection(userId).doc(cartItemId);
    final gearItemDocRef = _firestore.collection('gear_items').doc(gearItemId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot latestCartItemSnapshot = await transaction.get(cartItemDocRef);
      DocumentSnapshot latestGearItemSnapshot = await transaction.get(gearItemDocRef);

      if (!latestCartItemSnapshot.exists) {
        throw Exception("Cart item not found in database during transaction.");
      }
      if (!latestGearItemSnapshot.exists) {
        // If the original gear item doesn't exist, we can't update its stock.
        // Still update cart quantity if needed, but log a warning.
        print("Warning: Original gear item $gearItemId not found for stock adjustment.");
        transaction.update(cartItemDocRef, {'quantity': newQuantity});
        return; // Exit transaction, but allow cart quantity update
      }

      int currentQuantityInCart = (latestCartItemSnapshot.data() as Map<String, dynamic>)['quantity'] ?? 0;
      int currentAvailableQtyInGearItem = (latestGearItemSnapshot.data() as Map<String, dynamic>)['available_qty'] ?? 0;

      int quantityChange = newQuantity - currentQuantityInCart;

      if (quantityChange > 0) {
        // Increasing quantity
        if (currentAvailableQtyInGearItem < quantityChange) {
          throw Exception("Not enough available stock.");
        }
        transaction.update(gearItemDocRef, {
          'available_qty': FieldValue.increment(-quantityChange),
        });
      } else if (quantityChange < 0) {
        // Decreasing quantity
        transaction.update(gearItemDocRef, {
          'available_qty': FieldValue.increment(-quantityChange), // -change makes it +
        });
      }

      // Update the quantity in the cart item
      transaction.update(cartItemDocRef, {'quantity': newQuantity});
    });
  }

  /// Removes a cart item and returns its quantity to the gear item stock.
  /// This operation is performed as a Firestore Transaction.
  Future<void> removeCartItemAndReturnStock(
      String userId, String cartItemId, String gearItemId, int quantityInCart) async {
    final cartItemDocRef = _userCartItemsCollection(userId).doc(cartItemId);
    final gearItemDocRef = _firestore.collection('gear_items').doc(gearItemId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot cartSnapshot = await transaction.get(cartItemDocRef);
      DocumentSnapshot gearItemSnapshot = await transaction.get(gearItemDocRef);

      if (!cartSnapshot.exists) {
        print('Warning: Cart item $cartItemId not found during removal (it might have been removed already).');
        return; // Item already gone, nothing to do.
      }

      if (gearItemSnapshot.exists) {
        // Return the quantity that was in the cart item back to the main stock
        transaction.update(gearItemDocRef, {
          'available_qty': FieldValue.increment(quantityInCart),
        });
        print('Stock returned for item $gearItemId. Returned $quantityInCart units.');
      } else {
        print('Warning: Original gear item $gearItemId not found for stock return during cart removal. Cart item still removed.');
      }

      // Always delete the cart item
      transaction.delete(cartItemDocRef);
    });
  }

  /// Clears all items from a user's cart and returns all quantities to original stock.
  /// This uses a batch write for efficiency.
  Future<void> clearUserCartAndReturnStock(String userId) async {
    final cartItemsSnapshot = await _userCartItemsCollection(userId).get();
    WriteBatch batch = _firestore.batch();

    for (var doc in cartItemsSnapshot.docs) {
      final data = doc.data();
      String gearItemId = data['item_id'] ?? '';
      int quantityInCart = data['quantity'] ?? 0;

      // Return stock to the original gear item
      if (gearItemId.isNotEmpty && quantityInCart > 0) {
        DocumentReference gearItemRef = _firestore.collection('gear_items').doc(gearItemId);
        batch.update(gearItemRef, {'available_qty': FieldValue.increment(quantityInCart)});
      }

      // Delete the cart item from the batch
      batch.delete(doc.reference);
    }

    // Commit all operations in a single batch
    await batch.commit();
  }

  /// Creates a new order document after checkout.
  Future<void> createOrder(String userId, List<CartItem> items, double orderTotal) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'items': items.map((item) => item.toFirestore()).toList(), // Convert cart items to Firestore maps
        'orderTotal': orderTotal,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'pending', // Initial status
      });
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }
}