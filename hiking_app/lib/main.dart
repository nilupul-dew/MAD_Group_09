import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ));
  }
}
