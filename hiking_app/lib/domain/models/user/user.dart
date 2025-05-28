class UserModel {
  final String userId;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? email;
  final String? gender;
  final String? country;
  final String? profileImage;
  final String signInProvider;
  final DateTime createdDate;

  UserModel({
    required this.userId,
    required this.phone,
    required this.signInProvider,
    required this.createdDate,
    this.firstName,
    this.lastName,
    this.address,
    this.email,
    this.gender,
    this.country,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phone': phone,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'address': address ?? '',
      'email': email ?? '',
      'gender': gender ?? '',
      'country': country ?? '',
      'profileImage': profileImage ?? '',
      'signInProvider': signInProvider,
      'createdDate': createdDate,
    };
  }
}
