import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/user/authentication_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/user/display_name_screen.dart';
import 'domain/location-viewmodels/place_viewmodel.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("🚀 MyApp build method called");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaceViewModel()),
        // Add other providers here if you have more ViewModels
      ],
      child: MaterialApp(
        title: 'Amba Camping',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
        home: const AuthWrapper(),
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/display-name': (context) => const DisplayNameScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Check if user needs to complete profile setup
          if (user.displayName == null || user.displayName!.isEmpty) {
            return const DisplayNameScreen();
          }

          return const HomeScreen();
        }

        // If user is not logged in
        return const AuthScreen();
      },
    );
  }
}
