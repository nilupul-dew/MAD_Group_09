// lib/data/models/cart_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String cartItemId; // ID of the document in 'carts/userId/items' collection
  final String gearItemId; // ID of the original item from 'gear_items' collection
  final String name;
  final String imageUrl;
  final double rentPricePerDay;
  final int quantity;
  final int rentalDays;
  final DateTime startDate;

  CartItem({
    required this.cartItemId,
    required this.gearItemId,
    required this.name,
    required this.imageUrl,
    required this.rentPricePerDay,
    required this.quantity,
    required this.rentalDays,
    required this.startDate,
  });

  // Factory constructor to create a CartItem from a Firestore DocumentSnapshot
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      cartItemId: doc.id,
      gearItemId: data['item_id'] ?? '',
      name: data['name'] ?? 'N/A',
      imageUrl: data['image_url'] ?? 'https://via.placeholder.com/150', // Default placeholder
      rentPricePerDay: (data['rent_price_per_day'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as int?) ?? 1,
      rentalDays: (data['rental_days'] as int?) ?? 1,
      startDate: (data['start_date'] as Timestamp).toDate(),
    );
  }

  // Method to convert CartItem to a Map for Firestore (useful when adding/updating)
  Map<String, dynamic> toFirestore() {
    return {
      'item_id': gearItemId,
      'name': name,
      'image_url': imageUrl,
      'rent_price_per_day': rentPricePerDay,
      'quantity': quantity,
      'rental_days': rentalDays,
      'start_date': Timestamp.fromDate(startDate),
      // Add other fields you might have for a cart item
    };
  }

  // A copyWith method for easily creating a new instance with updated properties
  CartItem copyWith({
    String? cartItemId,
    String? gearItemId,
    String? name,
    String? imageUrl,
    double? rentPricePerDay,
    int? quantity,
    int? rentalDays,
    DateTime? startDate,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      gearItemId: gearItemId ?? this.gearItemId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rentPricePerDay: rentPricePerDay ?? this.rentPricePerDay,
      quantity: quantity ?? this.quantity,
      rentalDays: rentalDays ?? this.rentalDays,
      startDate: startDate ?? this.startDate,
    );
  }
}