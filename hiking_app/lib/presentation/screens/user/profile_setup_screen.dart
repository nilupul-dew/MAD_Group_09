import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../services/user/auth_service.dart';
import '../home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _addressController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _selectedGender;
  String? _selectedCountry;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _countries = [
    'Sri Lanka',
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete your profile"),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipToHome,
            child: const Text("Skip", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set up your profile",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You can always update this later",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Profile Image Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImageBytes != null
                      ? MemoryImage(_selectedImageBytes!)
                      : null,
                  child: _selectedImageBytes == null
                      ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text("Tap to add profile photo",
                  style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 32),

            // Address Field
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),

            // Country Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Complete Setup",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      await _authService.updateUserProfile(
        address: _addressController.text.trim(),
        gender: _selectedGender,
        country: _selectedCountry,
        profileImage: _selectedImageBytes,
        imageName: _selectedImageName,
      );

      _navigateToHome();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipToHome() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
