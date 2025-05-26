import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/domain/models/gear_item.dart'; // Import your Item model

class ItemFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Gear Items Operations ---

  /// Fetches a single gear item by its ID.
  Future<Item?> getGearItem(String itemId) async {
    try {
      DocumentSnapshot doc = await _db.collection('gear_items').doc(itemId).get();
      if (doc.exists) {
        return Item.fromFirestore(doc);
      } else {
        print('Gear item with ID $itemId not found.');
        return null;
      }
    } catch (e) {
      print('Error getting gear item: $e');
      return null;
    }
  }

  /// Fetches all gear items.
  Stream<List<Item>> getGearItems() {
    return _db.collection('gear_items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
    });
  }

  /// Adds a new gear item.
  Future<void> addGearItem(Item item) async {
    try {
      await _db.collection('gear_items').add(item.toFirestore());
      print('Gear item "${item.name}" added successfully.');
    } catch (e) {
      print('Error adding gear item: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  /// Updates an existing gear item.
  Future<void> updateGearItem(Item item) async {
    try {
      await _db.collection('gear_items').doc(item.id).update(item.toFirestore());
      print('Gear item "${item.name}" updated successfully.');
    } catch (e) {
      print('Error updating gear item: $e');
      rethrow;
    }
  }

  /// Deletes a gear item by its ID.
  Future<void> deleteGearItem(String itemId) async {
    try {
      await _db.collection('gear_items').doc(itemId).delete();
      print('Gear item with ID $itemId deleted successfully.');
    } catch (e) {
      print('Error deleting gear item: $e');
      rethrow;
    }
  }

  // --- Cart Operations ---

  /// Adds an item to the user's cart, handling stock updates.
  /// Returns true if successful, false otherwise.
  Future<bool> addItemToCart({
    required String userId,
    required String itemId,
    required String itemName,
    required String itemImageUrl,
    required double itemRentPricePerDay,
    required int quantity,
    required int rentalDays,
    required DateTime startDate,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        // Get the latest snapshot of the gear item
        final gearItemDocRef = _db.collection('gear_items').doc(itemId);
        DocumentSnapshot latestGearItemSnapshot = await transaction.get(gearItemDocRef);

        if (!latestGearItemSnapshot.exists) {
          throw Exception("Item not found in inventory. Cannot add to cart.");
        }

        int currentAvailableQtyInDb = (latestGearItemSnapshot.data() as Map<String, dynamic>)['available_qty'] ?? 0;

        if (currentAvailableQtyInDb < quantity) {
          throw Exception("Not enough stock available for $itemName. Only $currentAvailableQtyInDb units remaining.");
        }

        // Decrement the available quantity in the gear_items collection
        transaction.update(gearItemDocRef, {
          'available_qty': currentAvailableQtyInDb - quantity,
        });

        // Reference to the user's cart items subcollection
        final cartItemsRef = _db.collection('carts').doc(userId).collection('items');

        // Check if the item already exists in the cart for the given rental period
        final existingCartItemQuery = await cartItemsRef
            .where('item_id', isEqualTo: itemId)
            .where('start_date', isEqualTo: Timestamp.fromDate(startDate))
            .where('rental_days', isEqualTo: rentalDays)
            .limit(1)
            .get();

        if (existingCartItemQuery.docs.isNotEmpty) {
          // Item already in cart with same details, update quantity
          final existingCartItemDoc = existingCartItemQuery.docs.first;
          int currentQuantityInCart = (existingCartItemDoc.data())['quantity'] ?? 0;
          transaction.update(existingCartItemDoc.reference, {
            'quantity': currentQuantityInCart + quantity,
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
            'quantity': quantity,
            'rental_days': rentalDays,
            'start_date': Timestamp.fromDate(startDate),
            'added_at': FieldValue.serverTimestamp(),
          };
          transaction.set(cartItemsRef.doc(), cartItemData); // Use set with auto-generated ID
          print('New cart item added for $itemName.');
        }
      });
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  // You can add more cart operations here, e.g., getCartItems, removeCartItem, etc.
}