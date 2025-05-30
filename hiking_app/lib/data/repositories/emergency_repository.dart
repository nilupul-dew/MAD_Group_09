import 'package:hiking_app/domain/models/sos/emergency_contact.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyContact>> getEmergencyContacts(String userId);
  Future<void> addEmergencyContact(String userId, EmergencyContact contact);
  Future<void> deleteEmergencyContact(String userId, String contactId);
}
