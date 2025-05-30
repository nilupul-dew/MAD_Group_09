import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final String capacity;
  final String price;
  final String listedBy;
  final VoidCallback onTap;
  final Color topColor;
  final Color bottomColor;
  final VoidCallback onCartTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  const ItemCard({
    super.key,
    required this.assetImagePath,
    required this.title,
    required this.capacity,
    required this.price,
    required this.listedBy,
    required this.onTap,
    required this.topColor,
    required this.bottomColor,
    required this.onCartTap,
    required this.onFavoriteTap,
    required this.onShareTap,
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
            children: [
              // Image section with gradient/solid color background
              Container(
                height: cardWidth * 0.9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topColor, bottomColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        assetImagePath,
                        height: cardWidth * 0.6,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 12,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onCartTap,
                              customBorder: const CircleBorder(),
                              splashColor: Colors.white24,
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.shopping_cart,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onFavoriteTap,
                              customBorder: const CircleBorder(),
                              splashColor: Colors.white24,
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.favorite,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onShareTap,
                              customBorder: const CircleBorder(),
                              splashColor: const Color.fromARGB(60, 16, 106, 8),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.share,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom white section
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Capacity : ',
                            style: TextStyle(fontSize: 13),
                          ),
                          TextSpan(
                            text: capacity,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Charge per day ',
                            style: TextStyle(fontSize: 13),
                          ),
                          TextSpan(
                            text: price,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Listed by : $listedBy",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
