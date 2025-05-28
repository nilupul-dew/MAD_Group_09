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
  Country selectedCountry = Country.parse('LK'); // Use country code
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _startPhoneVerification() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    final fullPhoneNumber = '+${selectedCountry.phoneCode}$phone';

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => OTPScreen(
                    phoneNumber: fullPhoneNumber,
                    verificationId: verificationId,
                  ),
            ),
          );
        },
        onError: (error) => _showError(error),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _navigateToHome();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final userCredential = await _authService.signInWithFacebook();
      if (userCredential != null) {
        _navigateToHome();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleEmailSignIn() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showError('Enter both email and password');
        return;
      }

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _navigateToHome();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Sign up or Log in",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildCountryPicker(),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixText: '+${selectedCountry.phoneCode} ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Phone number',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startPhoneVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Continue with Phone",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleEmailSignIn,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text("Continue with Email"),
                  ),
                ),
                const SizedBox(height: 8),
                _socialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: "Continue with Google",
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: 8),
                _socialButton(
                  icon: Icons.facebook,
                  label: "Continue with Facebook",
                  onPressed: _handleFacebookSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryPicker() {
    return InkWell(
      onTap:
          () => showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (country) => setState(() => selectedCountry = country),
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
