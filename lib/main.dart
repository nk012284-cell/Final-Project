import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/Onboarding_Scrrens/mainsliderscreen.dart';
import 'package:mobil_app_project/Screens/uthentication/loginemptypage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Mainsliderscreen(),
    );
  }
}
