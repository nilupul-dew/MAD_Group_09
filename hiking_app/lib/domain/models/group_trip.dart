class GroupTrip {
  String title;
  String description;
  String location;
  DateTime date;
  int maxMembers;

  GroupTrip({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.maxMembers,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'maxMembers': maxMembers,
    };
  }
}
