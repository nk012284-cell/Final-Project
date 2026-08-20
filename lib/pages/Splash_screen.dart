import 'package:flutter/material.dart';
import 'package:mobil_app_project/pages/Onboarding_Screen.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});
  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  void initState() {
    super.initState();
    // Automatically navigates to OnboardingScreen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainSlider()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff108244),
      body: SafeArea(
        child: Stack(
          children: [
            // Center Logo / Title
            Center(
              child: Text(
                'Luxeyline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontFamily: 'Georgia', // Use 'Playfair Display' or 'Bodoni' for an exact match
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            // Bottom Version Text
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Version 1.56.2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
