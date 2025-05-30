import 'package:hiking_app/domain/models/sos/emergency_contact.dart';
import '../../data/repositories/emergency_repository.dart';

class ManageEmergencyContacts {
  final EmergencyRepository repository;

  ManageEmergencyContacts(this.repository);

  Future<List<EmergencyContact>> loadContacts(String userId) async {
    return await repository.getEmergencyContacts(userId);
  }

  Future<void> saveContact(String userId, EmergencyContact contact) async {
    await repository.addEmergencyContact(userId, contact);
  }

  Future<void> deleteContact(String userId, String contactId) async {
    await repository.deleteEmergencyContact(userId, contactId);
  }
}
