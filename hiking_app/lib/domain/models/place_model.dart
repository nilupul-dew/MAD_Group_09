class PlaceModel {
  final String name;
  final String locationName;
  final String province;
  final String district;
  final String imageUrl;
  final String type;
  final String category;
  final String description;
  final List<String> suitableMonths;

  PlaceModel({
    required this.name,
    required this.locationName,
    required this.province,
    required this.district,
    required this.imageUrl,
    required this.type,
    required this.category,
    required this.description,
    required this.suitableMonths,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'] ?? '',
      locationName: json['locationName'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      suitableMonths: List<String>.from(json['suitableMonths'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'locationName': locationName,
      'imageUrl': imageUrl,
      'type': type,
      'category': category,
      'description': description,
      'suitableMonths': suitableMonths,
    };
  }
}
