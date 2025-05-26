import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiking_app/firebase_options.dart';
import 'package:hiking_app/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
              Text("search bar and logo", style: TextStyle(color: Colors.red)),
        ),
        body: HomeScreen(),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
