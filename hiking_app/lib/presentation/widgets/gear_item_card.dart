// lib/presentation/widgets/gear_item_card.dart
import 'package:flutter/material.dart';
import 'package:hiking_app/domain/models/gear_item.dart'; // Ensure this path is correct

class GearItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const GearItemCard({super.key, required this.item, required this.onTap});

  // Helper getter to safely get the first image URL
  String get _cardImageUrl {
    String selectedUrl;
    if (item.image.isNotEmpty) {
      selectedUrl = item.image[0];
      print('DEBUG: GearItemCard - Image URL from item.image[0]: $selectedUrl');
    } else {
      selectedUrl = 'https://via.placeholder.com/150/CCCCCC/000000?text=No+Image';
      print('DEBUG: GearItemCard - Image URL (default placeholder): $selectedUrl');
    }
    return selectedUrl;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(8),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                _cardImageUrl, // Use the helper getter here
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('DEBUG: GearItemCard - Image loading error for URL: $_cardImageUrl - Error: $error');
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Available: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          TextSpan(
                            text: '${item.availableQty}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Per Day: Rs.${item.rentPricePerDay}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}