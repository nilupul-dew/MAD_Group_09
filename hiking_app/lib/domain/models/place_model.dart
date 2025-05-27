class PlaceModel {
  final String name;
  final String locationName;
  final String province; // New
  final String district; // New
  final String category;
  final String type;
  final String description;
  final List<String> suitableMonths;
  final String imageUrl; // main image URL
  final List<String> images; // New: for multiple images carousel
  final double latitude;
  final double longitude;
  final String? videoUrl;

  PlaceModel({
    required this.name,
    required this.locationName,
    required this.province,
    required this.district,
    required this.category,
    required this.type,
    required this.description,
    required this.suitableMonths,
    required this.imageUrl,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.videoUrl,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final latitude = (location['latitude'] ?? 0).toDouble();
    final longitude = (location['longitude'] ?? 0).toDouble();

    return PlaceModel(
      name: json['name'] ?? '',
      locationName: json['locationName'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      suitableMonths: List<String>.from(json['suitableMonths'] ?? []),
      latitude: latitude,
      longitude: longitude,
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'locationName': locationName,
      'province': province,
      'district': district,
      'imageUrl': imageUrl,
      'images': images,
      'type': type,
      'category': category,
      'description': description,
      'suitableMonths': suitableMonths,
      'location': {'latitude': latitude, 'longitude': longitude},
      if (videoUrl != null) 'videoUrl': videoUrl,
    };
  }
}
