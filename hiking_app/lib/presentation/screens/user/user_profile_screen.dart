import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/presentation/screens/user/authentication_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/firebase_services/user/auth_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGender;
  String? _selectedCountry;
  // File? _newProfileImage;
  // String? _currentProfileImageUrl;
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;
  bool _isEditing = false;

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
    'Other Country',
  ];

  // Mock data for camping activities - replace with real data later
  final Map<String, dynamic> _campingStats = {
    'totalTrips': 12,
    'gearListed': 8,
    'communityPosts': 24,
    'gearRented': 15,
    'reviewsGiven': 18,
    'memberSince': '2023',
    'favoriteLocations': 6,
    'upcomingTrips': 3,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Load from Firebase Auth
      final names = (user.displayName ?? '').split(' ');
      if (names.isNotEmpty) {
        _firstNameController.text = names.first;
        if (names.length > 1) {
          _lastNameController.text = names.sublist(1).join(' ');
        }
      }
      _emailController.text = user.email ?? '';

      // Load additional data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _addressController.text = data['address'] ?? '';
          final genderFromDB = data['gender'] as String?;
          _selectedGender =
              _genders.contains(genderFromDB) ? genderFromDB : null;
          final countryFromDB = data['country'] as String?;
          _selectedCountry =
              _countries.contains(countryFromDB) ? countryFromDB : null;
          _existingImageUrl = data['profileImage'] as String?;
        });
      }
    } catch (e) {
      _showError('Failed to load user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black54),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEditing,
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                "Save",
                style: TextStyle(color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _getProfileImage(),
                                  child: _getProfileImage() == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          '${_firstNameController.text} ${_lastNameController.text}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Member Since Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Member since ${_campingStats['memberSince']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Camping Activities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.hiking,
                                title: 'Total Trips',
                                value: '${_campingStats['totalTrips']}',
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.backpack,
                                title: 'Gear Listed',
                                value: '${_campingStats['gearListed']}',
                                color: const Color(0xFFFF8F00),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.forum,
                                title: 'Posts',
                                value: '${_campingStats['communityPosts']}',
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.star,
                                title: 'Reviews',
                                value: '${_campingStats['reviewsGiven']}',
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Activity Summary
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildActivityItem(
                                Icons.calendar_month,
                                'Upcoming Trips',
                                '${_campingStats['upcomingTrips']} trips planned',
                                const Color(0xFF2E7D32),
                              ),
                              _buildActivityItem(
                                Icons.favorite,
                                'Favorite Locations',
                                '${_campingStats['favoriteLocations']} saved spots',
                                const Color(0xFFE91E63),
                              ),
                              _buildActivityItem(
                                Icons.handshake,
                                'Gear Rentals',
                                '${_campingStats['gearRented']} items rented',
                                const Color(0xFFFF8F00),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Profile Details (Expandable)
                        if (_isEditing) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  "First Name",
                                  _firstNameController,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  "Last Name",
                                  _lastNameController,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  "Email",
                                  _emailController,
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  "Address",
                                  _addressController,
                                  enabled: _isEditing,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                // Gender Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  decoration: const InputDecoration(
                                    labelText: "Gender",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _genders.map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedGender = value,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Country Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  decoration: const InputDecoration(
                                    labelText: "Country",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _countries.map((country) {
                                    return DropdownMenuItem(
                                      value: country,
                                      child: Text(country),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedCountry = value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Logout Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton.icon(
                            onPressed: _showLogoutDialog,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (_existingImageUrl != null) {
      return NetworkImage(_existingImageUrl!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        print('byte image: $bytes');
        final compressedBytes = await _authService.compressImage(bytes);

        if (compressedBytes != null) {
          setState(() {
            _selectedImageBytes = compressedBytes;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedImageBytes = null;
    });
    _loadUserData();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      await _authService.updateDisplayName(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      await _authService.updateUserProfile(
        address: _addressController.text.trim(),
        gender: _selectedGender,
        country: _selectedCountry,
        profileImage: _selectedImageBytes,
        imageName: _selectedImageName,
      );

      setState(() {
        _isEditing = false;
        _selectedImageBytes = null;
      });

      _showSuccess('Profile updated successfully');
      _loadUserData();
    } catch (e) {
      _showError('Failed to update profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to logout: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
