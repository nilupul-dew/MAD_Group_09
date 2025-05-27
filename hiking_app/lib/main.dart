import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hiking_app/firebase_options.dart';
import 'package:hiking_app/presentation/screens/authentication_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(home: AuthScreen()));
}

