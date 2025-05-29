import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/firebase_services/user/auth_service.dart';
import 'profile_setup_screen.dart';

/*This page should be replaced with home screen - especially built for testing */

class DisplayNameScreen extends StatefulWidget {
  const DisplayNameScreen({super.key});

  @override
  State<DisplayNameScreen> createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState extends State<DisplayNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  void _prefillData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      final names = user!.displayName!.split(' ');
      if (names.isNotEmpty) {
        _firstNameController.text = names.first;
        if (names.length > 1) {
          _lastNameController.text = names.sublist(1).join(' ');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set up your name"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What should we call you?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "This name will be visible to other users",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name *",
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDisplayName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDisplayName() async {
    final firstName = _firstNameController.text.trim();

    if (firstName.isEmpty) {
      _showError('First name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final lastName = _lastNameController.text.trim();
      //final displayName = lastName.isEmpty ? firstName : '$firstName $lastName';

      await _authService.updateDisplayName(firstName, lastName);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
