// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String category;
  final String description;
  final double rentPricePerDay;
  final int availableQty;
  final String imageUrl;
  final double rating;
  final String color;
  final Map<String, dynamic> specs;
  final String? nameLowercase; // New field for search

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rentPricePerDay,
    required this.availableQty,
    required this.imageUrl,
    required this.rating,
    required this.color,
    required this.specs,
    this.nameLowercase, // Make it optional or derive it in the constructor
  });

  // Factory constructor to create an Item from a Firestore DocumentSnapshot
  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      rentPricePerDay: (data['rent_price_per_day'] as num?)?.toDouble() ?? 0.0,
      availableQty: data['available_qty'] ?? 0,
      imageUrl: data['image'] ?? 'https://via.placeholder.com/150',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      color: data['color'] ?? '',
      specs: Map<String, dynamic>.from(data['specs'] ?? {}),
      nameLowercase: data['name_lowercase'] ?? (data['name'] as String?)?.toLowerCase(), // Derive if not present
    );
  }

  // Method to convert an Item to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'rent_price_per_day': rentPricePerDay,
      'available_qty': availableQty,
      'image': imageUrl,
      'rating': rating,
      'color': color,
      'specs': specs,
      'name_lowercase': name.toLowerCase(), // Ensure this is always saved
    };
  }
}