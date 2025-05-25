import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/firebase_options.dart';
import 'package:hiking_app/presentation/screens/forum_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Add this line
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // This widget is the root of your application.
  @override
  @override
  Widget build(BuildContext context) {
    print("🚀 MyApp build method called");
    return MaterialApp(
      title: 'Camping App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: ForumScreen(),
    );
  }
}
