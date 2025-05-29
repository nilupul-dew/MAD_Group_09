import 'package:flutter/material.dart';
import 'package:hiking_app/domain/models/location-models/place_model.dart';
import 'package:hiking_app/presentation/screens/app_bar.dart';
import 'package:hiking_app/presentation/widgets/location-widgets/weather_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//import 'package:hiking_app/presentation/widgets/daily_forecast_strip.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentIndex = 0;

  final Map<String, IconData> categoryIcons = {
    'Mountains': Icons.terrain,
    'Waterfalls': Icons.waterfall_chart,
    'Lakes': Icons.water,
    'Beaches': Icons.beach_access,
    'Forests': Icons.park,
  };

  final Map<String, Color> categoryColors = {
    'Mountains': Color.fromARGB(255, 168, 85, 18),
    'Waterfalls': Color.fromARGB(255, 136, 171, 216),
    'Lakes': Color.fromARGB(255, 123, 156, 124),
    'Beaches': Color.fromARGB(255, 151, 125, 99),
    'Forests': Color.fromARGB(255, 32, 100, 95),
  };

  final Map<String, IconData> typeIcons = {
    'Hiking Area': FontAwesomeIcons.personHiking,
    'Campsite': FontAwesomeIcons.campground,
  };

  @override
  void initState() {
    super.initState();
    if (widget.place.videoUrl != null && widget.place.videoUrl!.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.place.videoUrl!);
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControls: true,
      );
      _videoController!.initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _launchMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> mediaItems = [];

    if (_chewieController != null &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      mediaItems.add(
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    if (widget.place.images.isNotEmpty) {
      mediaItems.addAll(
        widget.place.images.map((url) {
          return Image.network(url, fit: BoxFit.cover, width: double.infinity);
        }),
      );
    }

    if (mediaItems.isEmpty) {
      mediaItems.add(
        Image.network(
          widget.place.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 250,
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              items: mediaItems,
              options: CarouselOptions(
                height: 250,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });

                  if (_videoController != null &&
                      _videoController!.value.isInitialized) {
                    index == 0
                        ? _videoController!.play()
                        : _videoController!.pause();
                  }
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: mediaItems.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = entry.key),
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.place.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.place.province}, ${widget.place.district}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _launchMaps(
                      widget.place.latitude,
                      widget.place.longitude,
                    ),
                    icon: const Icon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.red,
                      size: 22,
                    ),
                    label: const Text(
                      'Navigate',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFF4285F4)),
                      ),
                      minimumSize: const Size(100, 40),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
            const Divider(
              color: Color.fromARGB(255, 219, 219, 219), // subtle gray line
              thickness: 0.4, // thin line
              indent: 60, // same horizontal margin as Padding
              endIndent: 60,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                // 👈 Center the Column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // 👈 Center align content inside
                  children: [
                    Row(
                      mainAxisSize:
                          MainAxisSize.min, // 👈 Prevent full width expansion
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Color.fromARGB(255, 82, 162, 214),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.place.suitableMonths.join(",   "),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisSize:
                          MainAxisSize.min, // 👈 Prevent full width expansion
                      children: [
                        Icon(
                          typeIcons[widget.place.type] ?? Icons.category,
                          color: Colors.amber[700],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.place.type,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          categoryIcons[widget.place.category] ?? Icons.terrain,
                          color: categoryColors[widget.place.category] ??
                              Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.place.category,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(
              color: Color.fromARGB(255, 219, 219, 219), // subtle gray line
              thickness: 0.4, // thin line
              indent: 60, // same horizontal margin as Padding
              endIndent: 60,
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  widget.place.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 96, 96, 97),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherCard(
                    latitude: widget.place.latitude,
                    longitude: widget.place.longitude,
                  ),
                  const SizedBox(height: 2),
                  //DailyForecastStrip(forecasts: _generateMockForecasts()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //Todo-- add customer post or feedback
          ],
        ),
      ),
    );
  }
}
