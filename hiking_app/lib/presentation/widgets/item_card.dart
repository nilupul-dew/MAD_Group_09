import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final String capacity;
  final String price;
  final String listedBy;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.assetImagePath,
    required this.title,
    required this.capacity,
    required this.price,
    required this.listedBy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 24;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      assetImagePath,
                      height: cardWidth * 0.7,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: const [
                        Icon(Icons.shopping_cart_outlined,
                            color: Color.fromARGB(255, 0, 0, 0), size: 20),
                        SizedBox(height: 8),
                        Icon(Icons.favorite_border,
                            color: Color.fromARGB(255, 0, 0, 0), size: 20),
                        SizedBox(height: 8),
                        Icon(Icons.share,
                            color: Color.fromARGB(255, 0, 0, 0), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              // Text section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text("Capacity: "),
                        Text(
                          capacity,
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text("Per day: "),
                        Text(
                          price,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Listed by: $listedBy",
                      style:
                          const TextStyle(color: Colors.orange, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
