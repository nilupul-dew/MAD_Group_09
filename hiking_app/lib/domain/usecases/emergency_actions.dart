import 'package:geolocator/geolocator.dart';
import 'package:hiking_app/domain/models/sos/emergency_contact.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class EmergencyActions {
  Future<void> callEmergencyServices() async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: '119');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Cannot make phone calls';
      }
    } catch (e) {
      throw 'Error making emergency call: $e';
    }
  }

  Future<void> sendEmergencyMessage(
    List<EmergencyContact> contacts,
    Position? location,
  ) async {
    if (contacts.isEmpty) {
      throw 'No emergency contacts added';
    }
    String locationText = location != null
        ? 'Location: ${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)}'
        : 'Location: Unknown';
    String smsBody =
        'EMERGENCY! I need help immediately! $locationText Please call me or emergency services.';
    try {
      for (EmergencyContact contact in contacts) {
        final String phoneNumber = contact.phoneNumber.replaceAll(
          RegExp(r'[^\d+]'),
          '',
        );
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phoneNumber,
          query: 'body=${Uri.encodeComponent(smsBody)}',
        );
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      throw 'Error preparing emergency SMS: $e';
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw 'Error getting location: $e';
    }
  }

  Future<void> toggleFlashlight(bool isOn) async {
    try {
      if (isOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
    } catch (e) {
      throw 'Flashlight not available';
    }
  }

  Future<void> playAnimalSound(
    AudioPlayer audioPlayer,
    String animalType,
  ) async {
    try {
      String soundFile;
      switch (animalType) {
        case 'bear':
          soundFile = 'sounds/bear_deterrent.mp3';
          break;
        case 'wolf':
          soundFile = 'sounds/wolf_deterrent.mp3';
          break;
        case 'snake':
          soundFile = 'sounds/snake_deterrent.mp3';
          break;
        case 'general':
          soundFile = 'sounds/general_deterrent.mp3';
          break;
        default:
          soundFile = 'sounds/general_deterrent.mp3';
      }
      await audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      throw 'Error playing asset sound: $e';
    }
  }
}
