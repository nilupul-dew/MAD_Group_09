// lib/presentation/widgets/cart_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hiking_app/presentation/widgets/item/quantity_selector.dart'; // Ensure this path is correct

class CartCard extends StatelessWidget {
  final String cartItemId;
  final String gearItemId;
  final String itemName;
  final String imageUrl;
  final double price; // This is rentPricePerDay
  final int quantity; // Current quantity in cart
  final int rentalDays;
  final double itemTotalPrice;
  final DateTime startDate;

  // Callbacks for quantity change and item removal
  final VoidCallback onDecrementQuantity;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onRemoveItem;

  const CartCard({
    Key? key,
    required this.cartItemId,
    required this.gearItemId,
    required this.itemName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.rentalDays,
    required this.itemTotalPrice,
    required this.startDate,
    required this.onDecrementQuantity,
    required this.onIncrementQuantity,
    required this.onRemoveItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(
        0xFFFEF0EA,
      ), // Your desired hex color for the card background
      shadowColor: Colors.black,
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
                      QuantitySelector(
                        quantity: quantity,
                        onDecrement: onDecrementQuantity,
                        onIncrement: onIncrementQuantity,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'for $rentalDays days from ${DateFormat('MMM d').format(startDate)}',
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
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onRemoveItem,
            ),
          ],
        ),
      ),
    );
  }
}
