import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/firebase_services/user/auth_service.dart';
import 'otp_screen.dart';
import 'display_name_screen.dart';
import '../home_screen.dart';

/* Edit line 274 to redirect to the home page if registered user */
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Country selectedCountry = Country.parse('LK');
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isSignUp = true; // Toggle between sign up and sign in
  bool _isLoading = false;

  void _startPhoneVerification() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    final fullPhoneNumber = '+${selectedCountry.phoneCode}$phone';

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                phoneNumber: fullPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(error);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _handleSuccessfulAuth(userCredential.user!);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithFacebook();
      if (userCredential != null) {
        _handleSuccessfulAuth(userCredential.user!);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEmailAuthDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isDialogLoading = false;
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: !isDialogLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.email, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(_isSignUp ? "Sign up with Email" : "Sign in with Email"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setDialogState(() {
                            isPasswordVisible = !isPasswordVisible;
                          }),
                        ),
                      ),
                    ),
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              _showError('Please enter your email address');
                              return;
                            }

                            try {
                              await _authService.resetPassword(email);
                              _showSuccess('Reset link sent to $email');
                            } catch (e) {
                              _showError(e.toString());
                            }
                          },
                          child: const Text("Forgot Password?"),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isDialogLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            _showError('Enter both email and password');
                            return;
                          }

                          if (password.length < 6) {
                            _showError(
                              'Password must be at least 6 characters',
                            );
                            return;
                          }

                          setDialogState(() => isDialogLoading = true);

                          try {
                            late final userCredential;

                            if (_isSignUp) {
                              final userExists =
                                  await _authService.userExists(email: email);
                              if (userExists) {
                                _showError(
                                  'User already exists. Please sign in instead.',
                                );
                                setState(() => _isSignUp = false);
                                Navigator.pop(context);
                                return;
                              }

                              userCredential =
                                  await _authService.signUpWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                            } else {
                              userCredential =
                                  await _authService.signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                            }

                            if (userCredential.user != null) {
                              Navigator.pop(context);
                              _handleSuccessfulAuth(userCredential.user!);
                            }
                          } catch (e) {
                            _showError(e.toString());
                          } finally {
                            setDialogState(() => isDialogLoading = false);
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignUp ? "Sign up" : "Sign in"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleSuccessfulAuth(user) {
    // Check if this is a new user (needs display name setup)
    // For new users, displayName is usually null or empty
    final isNewUser = user.displayName == null ||
        user.displayName!.isEmpty ||
        user.metadata.creationTime?.difference(DateTime.now()).inMinutes.abs() <
            2;

    if (isNewUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DisplayNameScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
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
                Center(
                  child: Text(
                    _isSignUp ? "Sign up" : "Sign in",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _isSignUp
                        ? "Create your account to get started."
                        : "Welcome back! Please sign in",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 30),

                // Phone Number Section
                _buildCountryPicker(),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixText: '+${selectedCountry.phoneCode} ',
                    border: OutlineInputBorder(),
                    labelText: 'Phone number',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startPhoneVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3641F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Continue with Phone",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("or", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Social Sign In Buttons
                _socialButton(
                  icon: Icons.email_outlined,
                  iconColor: Colors.grey.shade700,
                  label:
                      _isSignUp ? "Sign up with Email" : "Sign in with Email",
                  onPressed: _isLoading ? null : _showEmailAuthDialog,
                ),
                const SizedBox(height: 12),
                _socialButton(
                  icon: FontAwesomeIcons.googlePlusG,
                  label: "Continue with Google",
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: 12),
                _socialButton(
                  icon: Icons.facebook,
                  iconColor: Colors.blue,
                  label: "Continue with Facebook",
                  onPressed: _isLoading ? null : _handleFacebookSignIn,
                ),

                const SizedBox(height: 32),

                // Toggle Sign Up/Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? "Already have an account? "
                          : "Don't have an account? ",
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(_isSignUp ? "Sign in" : "Sign up"),
                    ),
                  ],
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
      onTap: () => showCountryPicker(
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
    required VoidCallback? onPressed,
    Color iconColor = Colors.black,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor),
      label: Text(label),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
