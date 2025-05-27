import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Country selectedCountry = Country.parse('sri lanka');
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  void _startPhoneVerification() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    final fullPhoneNumber = '+${selectedCountry.phoneCode}$phone';

    _authService.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (verificationId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(phoneNumber: fullPhoneNumber),
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Sign up or Log in",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              /// Country Picker
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (country) {
                      setState(() {
                        selectedCountry = country;
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${selectedCountry.flagEmoji} ${selectedCountry.name} (+${selectedCountry.phoneCode})",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Phone Number Input
              TextField(
                controller: _phoneController,

                decoration: InputDecoration(
                  prefixText: '+${selectedCountry.phoneCode} ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Phone number',
                ),
              ),
              const SizedBox(height: 20),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startPhoneVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              /// Social Buttons (inactive for now)
              _socialButton(
                icon: Icons.email_outlined,
                label: "Continue with email",
                onPressed: () {
                  // TODO: Navigate to email login
                },
              ),
              const SizedBox(height: 8),
              _socialButton(
                icon: Icons.apple,
                label: "Continue with Apple",
                onPressed: () {
                  // TODO: Implement Apple login
                },
              ),
              const SizedBox(height: 8),
              _socialButton(
                icon: Icons.g_mobiledata_rounded,
                label: "Continue with Google",
                onPressed: () {
                  // TODO: Implement Google login
                },
              ),
              const SizedBox(height: 8),
              _socialButton(
                icon: Icons.facebook,
                label: "Continue with Facebook",
                onPressed: () {
                  // TODO: Implement Facebook login
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
