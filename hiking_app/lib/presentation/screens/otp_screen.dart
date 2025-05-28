import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart'; // Your home screen

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
final String verificationId;
  const OTPScreen({super.key, required this.phoneNumber,required this.verificationId,});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  String verificationId = ''; // Pass it from AuthScreen in real app

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _otpController,

              decoration: const InputDecoration(labelText: "OTP Code"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signInWithOTP(
                    verificationId: verificationId,
                    smsCode: _otpController.text.trim(),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Verify and Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
