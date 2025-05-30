class EmergencyContact {
  final String? id;
  final String name;
  final String phoneNumber;

  EmergencyContact({this.id, required this.name, required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'],
        name: json['name'],
        phoneNumber: json['phoneNumber'],
      );
}
