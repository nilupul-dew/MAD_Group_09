import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hiking_app/firebase_options.dart';
import 'package:hiking_app/presentation/screens/explore_screen.dart';
import 'package:hiking_app/presentation/viewmodels/place_viewmodel.dart';
//import 'package:hiking_app/presentation/screens/forecast_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaceViewModel()..loadPlaces(), // Load places on start
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hiking App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[100],
        ),

        home: const ExploreScreen(),
        //home: ForecastTestScreen(),
      ),
    );
  }
}
