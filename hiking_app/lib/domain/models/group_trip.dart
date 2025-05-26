import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Trip {
  final String id;
  final String title;
  final String destination;
  final String tripType;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final int maxMembers;
  final double budget;
  final String accommodationType;
  final String departureCity;
  final String transportationMode;
  final String activities;
  final String organizerName;
  final String organizerEmail;
  final String organizerPhone;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final int memberCount;
  final String status;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.tripType,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.maxMembers,
    required this.budget,
    required this.accommodationType,
    required this.departureCity,
    required this.transportationMode,
    required this.activities,
    required this.organizerName,
    required this.organizerEmail,
    required this.organizerPhone,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    required this.memberCount,
    this.status = 'active',
  });

  factory Trip.fromMap(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      title: data['title'] ?? '',
      destination: data['destination'] ?? '',
      tripType: data['tripType'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      duration: data['duration'] ?? 0,
      maxMembers: data['maxMembers'] ?? 0,
      budget: (data['budget'] ?? 0).toDouble(),
      accommodationType: data['accommodationType'] ?? '',
      departureCity: data['departureCity'] ?? '',
      transportationMode: data['transportationMode'] ?? '',
      activities: data['activities'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerEmail: data['organizerEmail'] ?? '',
      organizerPhone: data['organizerPhone'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      memberCount: data['memberCount'] ?? 0,
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'destination': destination,
      'tripType': tripType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'duration': duration,
      'maxMembers': maxMembers,
      'budget': budget,
      'accommodationType': accommodationType,
      'departureCity': departureCity,
      'transportationMode': transportationMode,
      'activities': activities,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
      'organizerPhone': organizerPhone,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'members': members,
      'memberCount': memberCount,
      'status': status,
    };
  }
}
