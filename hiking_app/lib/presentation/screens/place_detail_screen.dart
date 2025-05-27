import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking_app/domain/models/place_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

  // Method to open Google Maps navigation
  Future<void> _openMaps(double lat, double lng) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: const Color.fromARGB(255, 24, 21, 44),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: place.images.isNotEmpty ? place.images.length : 1,
                itemBuilder: (context, index) {
                  final imageUrl =
                      place.images.isNotEmpty
                          ? place.images[index]
                          : place.imageUrl; // fallback to main image
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                place.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${place.locationName}, ${place.district}, ${place.province}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                place.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            // Navigation button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () => _openMaps(place.latitude, place.longitude),
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate with Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 21, 44),
                ),
              ),
            ),

            // Placeholder for Weather card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                elevation: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Weather info here (Coming Soon)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            // Placeholder for Community Posts section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                elevation: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Community Posts Section (Replace with your friend\'s widget)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
