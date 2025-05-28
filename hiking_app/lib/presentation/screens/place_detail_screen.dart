// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:hiking_app/domain/models/place_model.dart';

// class PlaceDetailScreen extends StatelessWidget {
//   final PlaceModel place;

//   const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

//   // Launch Google Maps with coordinates
//   void _launchMaps(double lat, double lng) async {
//     final url = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not open maps.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(place.name),
//         backgroundColor: const Color.fromARGB(255, 244, 244, 245),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Carousel
//             if (place.images.isNotEmpty)
//               CarouselSlider(
//                 options: CarouselOptions(
//                   height: 250,
//                   viewportFraction: 1.0,
//                   enableInfiniteScroll: false,
//                 ),
//                 items:
//                     place.images.map((imageUrl) {
//                       return Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       );
//                     }).toList(),
//               )
//             else
//               // fallback to main image if no images list
//               Image.network(
//                 place.imageUrl,
//                 height: 250,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),

//             const SizedBox(height: 16),

//             // Place info: name, province, district
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 place.name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 4,
//               ),
//               child: Text(
//                 '${place.province}, ${place.district}',
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Description
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Text(
//                 place.description,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Navigation Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: ElevatedButton.icon(
//                 onPressed: () => _launchMaps(place.latitude, place.longitude),
//                 icon: const Icon(Icons.navigation),
//                 label: const Text('Navigate to Location'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 24, 21, 44),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // TODO: Add Weather Card here

//             // TODO: Add Community Posts/Reviews section here
//           ],
//         ),
//       ),
//     );
//   }
// }
//--------------above correct---------------------------//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:hiking_app/domain/models/place_model.dart';

// class PlaceDetailScreen extends StatefulWidget {
//   final PlaceModel place;

//   const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

//   @override
//   State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
// }

// class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize video player if videoUrl present
//     if (widget.place.videoUrl != null && widget.place.videoUrl!.isNotEmpty) {
//       _videoController = VideoPlayerController.network(widget.place.videoUrl!);
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: true,
//         looping: false,
//         showControls: true,
//       );
//       _videoController!.initialize().then((_) => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   // Launch Google Maps with coordinates
//   void _launchMaps(double lat, double lng) async {
//     final url = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not open maps.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Combine video player (if any) and images into media items list
//     final List<Widget> mediaItems = [];

//     if (_chewieController != null && _videoController!.value.isInitialized) {
//       mediaItems.add(
//         AspectRatio(
//           aspectRatio: _videoController!.value.aspectRatio,
//           child: Chewie(controller: _chewieController!),
//         ),
//       );
//     }

//     if (widget.place.images.isNotEmpty) {
//       mediaItems.addAll(
//         widget.place.images.map((url) {
//           return Image.network(url, fit: BoxFit.cover, width: double.infinity);
//         }),
//       );
//     }

//     // If no video and no images, fallback to main image
//     if (mediaItems.isEmpty) {
//       mediaItems.add(
//         Image.network(
//           widget.place.imageUrl,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: 250,
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.place.name),
//         backgroundColor: const Color.fromARGB(255, 243, 243, 243),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Media Carousel
//             CarouselSlider(
//               items: mediaItems,
//               options: CarouselOptions(
//                 height: 250,
//                 viewportFraction: 1.0,
//                 enableInfiniteScroll: false,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 },
//               ),
//             ),

//             // Slide indicator dots
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children:
//                   mediaItems.asMap().entries.map((entry) {
//                     return GestureDetector(
//                       onTap:
//                           () => setState(() {
//                             _currentIndex = entry.key;
//                           }),
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 4,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               _currentIndex == entry.key
//                                   ? Colors.blueAccent
//                                   : Colors.grey,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Text(
//                 '${widget.place.province}, ${widget.place.district}',
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.description,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: ElevatedButton.icon(
//                 onPressed:
//                     () => _launchMaps(
//                       widget.place.latitude,
//                       widget.place.longitude,
//                     ),
//                 icon: const Icon(Icons.navigation),
//                 label: const Text('Navigate to Location'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 24, 21, 44),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // TODO: Add Weather Card here

//             // TODO: Add Community Posts/Reviews section here
//           ],
//         ),
//       ),
//     );
//   }
// }
//---------------above work--------------//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:hiking_app/domain/models/place_model.dart';

// class PlaceDetailScreen extends StatefulWidget {
//   final PlaceModel place;

//   const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

//   @override
//   State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
// }

// class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize video player if videoUrl present
//     if (widget.place.videoUrl != null && widget.place.videoUrl!.isNotEmpty) {
//       _videoController = VideoPlayerController.network(widget.place.videoUrl!);
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: true,
//         looping: true,
//         showControls: true,
//       );
//       _videoController!.initialize().then((_) => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   // Launch Google Maps with coordinates
//   void _launchMaps(double lat, double lng) async {
//     final url = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not open maps.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Combine video player (if any) and images into media items list
//     final List<Widget> mediaItems = [];

//     if (_chewieController != null &&
//         _videoController != null &&
//         _videoController!.value.isInitialized) {
//       mediaItems.add(
//         AspectRatio(
//           aspectRatio: _videoController!.value.aspectRatio,
//           child: Chewie(controller: _chewieController!),
//         ),
//       );
//     }

//     if (widget.place.images.isNotEmpty) {
//       mediaItems.addAll(
//         widget.place.images.map((url) {
//           return Image.network(url, fit: BoxFit.cover, width: double.infinity);
//         }),
//       );
//     }

//     // If no video and no images, fallback to main image
//     if (mediaItems.isEmpty) {
//       mediaItems.add(
//         Image.network(
//           widget.place.imageUrl,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: 250,
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.place.name),
//         backgroundColor: const Color.fromARGB(255, 243, 243, 243),
//         foregroundColor: Colors.black, // Makes appbar text black for light bg
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Media Carousel
//             CarouselSlider(
//               items: mediaItems,
//               options: CarouselOptions(
//                 height: 250,
//                 viewportFraction: 1.0,
//                 enableInfiniteScroll: false,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _currentIndex = index;
//                   });

//                   if (_videoController != null &&
//                       _videoController!.value.isInitialized) {
//                     if (index == 0) {
//                       _videoController!.play();
//                     } else {
//                       _videoController!.pause();
//                     }
//                   }
//                 },
//               ),
//             ),

//             // Slide indicator dots
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children:
//                   mediaItems.asMap().entries.map((entry) {
//                     return GestureDetector(
//                       onTap:
//                           () => setState(() {
//                             _currentIndex = entry.key;
//                           }),
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 4,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               _currentIndex == entry.key
//                                   ? Colors.blueAccent
//                                   : Colors.grey,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Text(
//                 '${widget.place.province}, ${widget.place.district}',
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.description,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: ElevatedButton.icon(
//                 onPressed:
//                     () => _launchMaps(
//                       widget.place.latitude,
//                       widget.place.longitude,
//                     ),
//                 icon: const Icon(Icons.navigation),
//                 label: const Text('Navigate to Location'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 24, 21, 44),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // TODO: Add Weather Card here

//             // TODO: Add Community Posts/Reviews section here
//           ],
//         ),
//       ),
//     );
//   }
// }
//-------------------------------------//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:hiking_app/domain/models/place_model.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class PlaceDetailScreen extends StatefulWidget {
//   final PlaceModel place;

//   const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

//   @override
//   State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
// }

// class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.place.videoUrl != null && widget.place.videoUrl!.isNotEmpty) {
//       _videoController = VideoPlayerController.network(widget.place.videoUrl!);
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: true,
//         looping: true,
//         showControls: true,
//       );
//       _videoController!.initialize().then((_) => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   void _launchMaps(double lat, double lng) async {
//     final url = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not open maps.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> mediaItems = [];

//     if (_chewieController != null &&
//         _videoController != null &&
//         _videoController!.value.isInitialized) {
//       mediaItems.add(
//         AspectRatio(
//           aspectRatio: _videoController!.value.aspectRatio,
//           child: Chewie(controller: _chewieController!),
//         ),
//       );
//     }

//     if (widget.place.images.isNotEmpty) {
//       mediaItems.addAll(
//         widget.place.images.map((url) {
//           return Image.network(url, fit: BoxFit.cover, width: double.infinity);
//         }),
//       );
//     }

//     if (mediaItems.isEmpty) {
//       mediaItems.add(
//         Image.network(
//           widget.place.imageUrl,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: 250,
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.place.name),
//         backgroundColor: const Color.fromARGB(255, 243, 243, 243),
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CarouselSlider(
//               items: mediaItems,
//               options: CarouselOptions(
//                 height: 250,
//                 viewportFraction: 1.0,
//                 enableInfiniteScroll: false,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _currentIndex = index;
//                   });

//                   if (_videoController != null &&
//                       _videoController!.value.isInitialized) {
//                     if (index == 0) {
//                       _videoController!.play();
//                     } else {
//                       _videoController!.pause();
//                     }
//                   }
//                 },
//               ),
//             ),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children:
//                   mediaItems.asMap().entries.map((entry) {
//                     return GestureDetector(
//                       onTap:
//                           () => setState(() {
//                             _currentIndex = entry.key;
//                           }),
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 4,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               _currentIndex == entry.key
//                                   ? Colors.blueAccent
//                                   : Colors.grey,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.place.name,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed:
//                         () => _launchMaps(
//                           widget.place.latitude,
//                           widget.place.longitude,
//                         ),
//                     icon: const Icon(
//                       FontAwesomeIcons.locationDot,
//                       color: Color.fromARGB(255, 243, 33, 33),
//                       size: 24,
//                     ), // Google Maps blue color
//                     label: const Text(
//                       'Navigate',
//                       style: TextStyle(color: Color(0xFF4285F4)),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           Colors.white, // White background for button
//                       elevation: 0, // Remove shadow for cleaner look
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         side: const BorderSide(
//                           color: Color(0xFF4285F4),
//                         ), // Border with Google Blue
//                       ),
//                       minimumSize: const Size(100, 40),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '${widget.place.province}, ${widget.place.district}',
//                     style: const TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.description,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // TODO: Add Weather Card here
//             // TODO: Add Community Posts/Reviews section here
//           ],
//         ),
//       ),
//     );
//   }
// }
//---------------------//
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:hiking_app/domain/models/place_model.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hiking_app/presentation/widgets/daily_forecast_strip.dart';
// import 'package:hiking_app/presentation/widgets/weather_card.dart';

// class PlaceDetailScreen extends StatefulWidget {
//   final PlaceModel place;

//   const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

//   @override
//   State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
// }

// class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.place.videoUrl != null && widget.place.videoUrl!.isNotEmpty) {
//       _videoController = VideoPlayerController.network(widget.place.videoUrl!);
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: true,
//         looping: true,
//         showControls: true,
//       );
//       _videoController!.initialize().then((_) => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   void _launchMaps(double lat, double lng) async {
//     final url = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       throw 'Could not open maps.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> mediaItems = [];

//     if (_chewieController != null &&
//         _videoController != null &&
//         _videoController!.value.isInitialized) {
//       mediaItems.add(
//         AspectRatio(
//           aspectRatio: _videoController!.value.aspectRatio,
//           child: Chewie(controller: _chewieController!),
//         ),
//       );
//     }

//     if (widget.place.images.isNotEmpty) {
//       mediaItems.addAll(
//         widget.place.images.map((url) {
//           return Image.network(url, fit: BoxFit.cover, width: double.infinity);
//         }),
//       );
//     }

//     if (mediaItems.isEmpty) {
//       mediaItems.add(
//         Image.network(
//           widget.place.imageUrl,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: 250,
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.place.name),
//         backgroundColor: const Color.fromARGB(255, 243, 243, 243),
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CarouselSlider(
//               items: mediaItems,
//               options: CarouselOptions(
//                 height: 250,
//                 viewportFraction: 1.0,
//                 enableInfiniteScroll: false,
//                 onPageChanged: (index, reason) {
//                   setState(() {
//                     _currentIndex = index;
//                   });

//                   if (_videoController != null &&
//                       _videoController!.value.isInitialized) {
//                     if (index == 0) {
//                       _videoController!.play();
//                     } else {
//                       _videoController!.pause();
//                     }
//                   }
//                 },
//               ),
//             ),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children:
//                   mediaItems.asMap().entries.map((entry) {
//                     return GestureDetector(
//                       onTap:
//                           () => setState(() {
//                             _currentIndex = entry.key;
//                           }),
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 4,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               _currentIndex == entry.key
//                                   ? Colors.blueAccent
//                                   : Colors.grey,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '${widget.place.province}, ${widget.place.district}',
//                     style: const TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed:
//                         () => _launchMaps(
//                           widget.place.latitude,
//                           widget.place.longitude,
//                         ),
//                     icon: const Icon(
//                       FontAwesomeIcons.locationDot,
//                       color: Color.fromARGB(255, 171, 8, 8), // Google Maps Blue
//                       size: 24,
//                     ),
//                     label: const Text(
//                       'Navigate',
//                       style: TextStyle(color: Color(0xFF4285F4)),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         side: const BorderSide(color: Color(0xFF4285F4)),
//                       ),
//                       minimumSize: const Size(100, 40),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 widget.place.description,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// weather section with card + forecast strip
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   WeatherCard(
//                     latitude: widget.place.latitude,
//                     longitude: widget.place.longitude,
//                   ),
//                   const SizedBox(height: 12),
//                   DailyForecastStrip(
//                     forecasts:
//                         [], // 👈 You need to pass real or mock forecast list here
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // TODO: Add Community Posts/Reviews section here
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------above  work -------------------//
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:hiking_app/domain/models/place_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking_app/presentation/widgets/daily_forecast_strip.dart';
import 'package:hiking_app/presentation/widgets/weather_card.dart';

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
      appBar: AppBar(
        title: Text(widget.place.name),
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        foregroundColor: Colors.black,
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
                    if (index == 0) {
                      _videoController!.play();
                    } else {
                      _videoController!.pause();
                    }
                  }
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  mediaItems.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            _currentIndex = entry.key;
                          }),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentIndex == entry.key
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
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        () => _launchMaps(
                          widget.place.latitude,
                          widget.place.longitude,
                        ),
                    icon: const Icon(
                      FontAwesomeIcons.locationDot,
                      color: Color.fromARGB(255, 171, 8, 8),
                      size: 24,
                    ),
                    label: const Text(
                      'Navigate',
                      style: TextStyle(color: Color(0xFF4285F4)),
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

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.place.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.place.suitableMonths.join(", ")}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.personHiking,
                        color: Color.fromARGB(255, 219, 162, 77),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.place.type}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.terrain,
                        color: Color.fromARGB(255, 168, 85, 18),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.place.category}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// weather section with card + forecast strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherCard(
                    latitude: widget.place.latitude,
                    longitude: widget.place.longitude,
                  ),
                  const SizedBox(height: 12),
                  DailyForecastStrip(forecasts: []),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TODO: Add Community Posts/Reviews section here
          ],
        ),
      ),
    );
  }
}
