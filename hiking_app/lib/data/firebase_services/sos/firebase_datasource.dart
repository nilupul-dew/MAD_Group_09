import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/data/repositories/emergency_repository.dart';
import 'package:hiking_app/domain/models/sos/emergency_contact.dart';

class FirebaseDataSource implements EmergencyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .get();
      return snapshot.docs
          .map(
            (doc) => EmergencyContact.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      throw 'Error loading contacts: $e';
    }
  }

  @override
  Future<void> addEmergencyContact(
    String userId,
    EmergencyContact contact,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .add({'name': contact.name, 'phoneNumber': contact.phoneNumber});
    } catch (e) {
      throw 'Error saving contact: $e';
    }
  }

  @override
  Future<void> deleteEmergencyContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency_contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      throw 'Error deleting contact: $e';
    }
  }
}
