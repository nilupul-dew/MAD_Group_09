// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String category;
  final String description;
  final double rentPricePerDay;
  final int availableQty;
  final List<String> image; // Correctly declared as List<String>
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
    required this.image, // This is a List<String>
    required this.rating,
    required this.color,
    required this.specs,
    this.nameLowercase, // Make it optional or derive it in the constructor
  });

  // Factory constructor to create an Item from a Firestore DocumentSnapshot
  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Correctly handle 'imageUrl' as a List<String>
    List<String> parsedImageUrls = [];
    if (data['image'] is List) {
      // Ensure each element in the list is treated as a string
      parsedImageUrls = List<String>.from(data['image'].map((url) => url.toString()));
    } else if (data['image'] is String && (data['image'] as String).isNotEmpty) {
      // Handle cases where 'image' might still be a single string for backward compatibility
      parsedImageUrls = [data['image'] as String];
    }
    // If parsedImageUrls is still empty, provide a default list with a placeholder
    if (parsedImageUrls.isEmpty) {
      parsedImageUrls = ['https://via.placeholder.com/150/CCCCCC/000000?text=No+Image'];
    }


    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      rentPricePerDay: (data['rent_price_per_day'] as num?)?.toDouble() ?? 0.0,
      availableQty: (data['available_qty'] as num?)?.toInt() ?? 0, // Ensure it's an int
      image: parsedImageUrls, // Use the correctly parsed List<String>
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
      'image': image, // This will correctly save the List<String>
      'rating': rating,
      'color': color,
      'specs': specs,
      'name_lowercase': name.toLowerCase(), // Ensure this is always saved
    };
  }
}