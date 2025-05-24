import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hiking_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        appBar: AppBar(title: Text("Firestore Example")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await db.collection("test3").add({
                "message": "Hello, Firestore!",
              });
            },
            child: Text("Add Document"),
          ),
        ),
      ),
    );
  }
}
