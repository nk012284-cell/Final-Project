import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/SetupAccount/setprofile.dart';

// ignore: camel_case_types
class completesetup extends StatefulWidget {
  const completesetup({super.key});

  @override
  State<completesetup> createState() => _completesetupState();
}

// ignore: camel_case_types
class _completesetupState extends State<completesetup> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button

              const SizedBox(height: 32),

              // Title
              const Text(
                "Welcome ,Aoran!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset("assets/images/sstup.png"),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return profile();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF138048),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Map Mockup Background
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final paintGreen = Paint()
      ..color = const Color(0xFFAED581)
      ..style = PaintingStyle.fill;

    // Green areas (parks)
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.65,
        size.width * 0.25,
        size.height * 0.35,
      ),
      paintGreen,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.65,
        size.height * 0.45,
        size.width * 0.35,
        size.height * 0.55,
      ),
      paintGreen,
    );

    // Road lines
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.5, 0);

    path.moveTo(size.width * 0.2, size.height);
    path.lineTo(size.width * 0.6, 0);

    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.2);

    path.moveTo(size.width * 0.4, size.height);
    path.lineTo(size.width, size.height * 0.6);

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Clipper for Pin Triangle
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}
