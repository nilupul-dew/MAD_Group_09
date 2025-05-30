import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hiking_app/core/utils/constants.dart';
import 'package:hiking_app/core/utils/snackbar_helper.dart';
import 'package:hiking_app/data/firebase_services/sos/firebase_datasource.dart';
import 'package:hiking_app/domain/models/sos/emergency_contact.dart';
import 'package:hiking_app/domain/usecases/emergency_actions.dart';
import 'package:hiking_app/domain/usecases/manage_emergency_contacts.dart';
import 'package:hiking_app/presentation/widgets/sos/animal_button.dart';
import 'package:hiking_app/presentation/widgets/sos/contact_row.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  final ManageEmergencyContacts _manageContacts = ManageEmergencyContacts(
    FirebaseDataSource(),
  );
  final EmergencyActions _emergencyActions = EmergencyActions();
  String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? 'aB1cD2eF3gH4iJ5kL6mN7oP8qR9s';
  List<EmergencyContact> emergencyContacts = [];
  bool isFlashlightOn = false;
  bool isSOSFlashing = false;
  Timer? sosTimer;
  AudioPlayer audioPlayer = AudioPlayer();
  Position? currentLocation;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    sosTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final contacts = await _manageContacts.loadContacts(currentUserId);
      setState(() {
        emergencyContacts = contacts;
      });
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _saveEmergencyContact(EmergencyContact contact) async {
    try {
      await _manageContacts.saveContact(currentUserId, contact);
      await _loadEmergencyContacts();
      SnackBarHelper.showSnackBar(context, 'Emergency contact added');
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _deleteEmergencyContact(String contactId) async {
    try {
      await _manageContacts.deleteContact(currentUserId, contactId);
      setState(() {
        emergencyContacts.removeWhere((contact) => contact.id == contactId);
      });
      SnackBarHelper.showSnackBar(context, 'Contact removed');
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _emergencyActions.getCurrentLocation();
      setState(() {
        currentLocation = position;
      });
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _callEmergencyServices() async {
    try {
      await _emergencyActions.callEmergencyServices();
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _sendEmergencyMessage() async {
    try {
      await _emergencyActions.sendEmergencyMessage(
        emergencyContacts,
        currentLocation,
      );
      SnackBarHelper.showSnackBar(
        context,
        'Emergency SMS prepared for ${emergencyContacts.length} contacts',
      );
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  Future<void> _toggleFlashlight() async {
    try {
      await _emergencyActions.toggleFlashlight(isFlashlightOn);
      setState(() {
        isFlashlightOn = !isFlashlightOn;
      });
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.toString());
    }
  }

  void _startSOSFlash() {
    if (isSOSFlashing) {
      _stopSOSFlash();
      return;
    }
    setState(() {
      isSOSFlashing = true;
    });
    _flashSOSPattern();
  }

  void _flashSOSPattern() async {
    if (!isSOSFlashing) return;
    try {
      for (int i = 0; i < 3; i++) {
        if (!isSOSFlashing) return;
        await TorchLight.enableTorch();
        await Future.delayed(Duration(milliseconds: 200));
        await TorchLight.disableTorch();
        await Future.delayed(Duration(milliseconds: 200));
      }
      await Future.delayed(Duration(milliseconds: 400));
      for (int i = 0; i < 3; i++) {
        if (!isSOSFlashing) return;
        await TorchLight.enableTorch();
        await Future.delayed(Duration(milliseconds: 600));
        await TorchLight.disableTorch();
        await Future.delayed(Duration(milliseconds: 200));
      }
      await Future.delayed(Duration(milliseconds: 400));
      for (int i = 0; i < 3; i++) {
        if (!isSOSFlashing) return;
        await TorchLight.enableTorch();
        await Future.delayed(Duration(milliseconds: 200));
        await TorchLight.disableTorch();
        await Future.delayed(Duration(milliseconds: 200));
      }
      await Future.delayed(Duration(milliseconds: 1000));
      if (isSOSFlashing) {
        _flashSOSPattern();
      }
    } catch (e) {
      SnackBarHelper.showSnackBar(context, 'Flashlight error');
      _stopSOSFlash();
    }
  }

  void _stopSOSFlash() async {
    setState(() {
      isSOSFlashing = false;
    });
    try {
      await TorchLight.disableTorch();
      setState(() {
        isFlashlightOn = false;
      });
    } catch (e) {
      print('Error stopping flashlight: $e');
    }
  }

  Future<void> _playAnimalSound(String animalType) async {
    try {
      await _emergencyActions.playAnimalSound(audioPlayer, animalType);
      SnackBarHelper.showSnackBar(
        context,
        'Playing $animalType deterrent sound',
      );
    } catch (e) {
      print('Error playing asset sound: $e');
      await SystemSound.play(SystemSoundType.alert);
      SnackBarHelper.showSnackBar(context, 'Playing fallback deterrent sound');
    }
  }

  void _showAddContactDialog() {
    String name = '';
    String phoneNumber = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => name = value,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => phoneNumber = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (name.isNotEmpty && phoneNumber.isNotEmpty) {
                final contact = EmergencyContact(
                  name: name,
                  phoneNumber: phoneNumber,
                );
                await _saveEmergencyContact(contact);
                Navigator.pop(context);
              } else {
                SnackBarHelper.showSnackBar(
                  context,
                  'Please enter valid name and phone number',
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('SOS Emergency'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 70,
              child: ElevatedButton(
                onPressed: _callEmergencyServices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'CALL 119',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.darkGray,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _showAddContactDialog,
                          icon: Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (emergencyContacts.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No emergency numbers added',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.mediumGray,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...emergencyContacts.map(
                      (contact) => ContactRow(
                        contact: contact,
                        onDelete: () => _deleteEmergencyContact(contact.id!),
                      ),
                    ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sendEmergencyMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Send Help Message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flashlight Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.darkGray,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _toggleFlashlight,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flashlight_on, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Turn On',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _startSOSFlash,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'SOS Flash',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animal Deterrent Sounds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.darkGray,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AnimalButton(
                          label: 'Bear',
                          icon: Icons.pets,
                          bgColor: AppConstants.secondaryRed.withOpacity(0.2),
                          iconColor: AppConstants.secondaryRed,
                          onPressed: () => _playAnimalSound('bear'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: AnimalButton(
                          label: 'Wolf',
                          icon: Icons.pets,
                          bgColor: AppConstants.blue.withOpacity(0.2),
                          iconColor: AppConstants.blue,
                          onPressed: () => _playAnimalSound('wolf'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AnimalButton(
                          label: 'Snake',
                          icon: Icons.waves,
                          bgColor: AppConstants.green.withOpacity(0.2),
                          iconColor: AppConstants.green,
                          onPressed: () => _playAnimalSound('snake'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: AnimalButton(
                          label: 'General',
                          icon: Icons.volume_up,
                          bgColor: AppConstants.lightRed.withOpacity(0.2),
                          iconColor: AppConstants.lightRed,
                          onPressed: () => _playAnimalSound('general'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.darkGray,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (currentLocation != null) ...[
                    Text(
                      'Lat: ${currentLocation!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Lng: ${currentLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Lat: 37.421998',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Lng: -122.084567',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (currentLocation != null) {
                          final Uri mapsUri = Uri.parse(
                            'https://maps.google.com/?q=${currentLocation!.latitude},${currentLocation!.longitude}',
                          );
                          try {
                            if (await canLaunchUrl(mapsUri)) {
                              await launchUrl(mapsUri);
                            }
                          } catch (e) {
                            SnackBarHelper.showSnackBar(
                              context,
                              'Cannot open maps',
                            );
                          }
                        } else {
                          _getCurrentLocation();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Open In Map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
