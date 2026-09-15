import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobil_app_project/screens/SetupAccount/setupcompleted.dart';
import 'package:image_picker/image_picker.dart';

// ignore: camel_case_types
class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

// ignore: camel_case_types
class _profileState extends State<profile> {
  final TextEditingController _locationController = TextEditingController();

  // Holds the picked image file. Null means no image selected yet.
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Opens the gallery, lets the user pick an image, and updates the state
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // compress a bit to keep file size reasonable
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Clears the selected image, reverting back to the default avatar
  void _deleteImage() {
    setState(() {
      _profileImage = null;
    });
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
                "Add a Profile Photo",
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

              // Centered avatar + delete icon
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Tapping the circle opens the gallery
                      GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 120,
                          // Show the picked image if available, else show
                          // a placeholder icon so it's clear it's tappable
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),

                      // Small camera badge bottom-right (optional visual cue)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 22,
                              color: Color(0xFF138048),
                            ),
                          ),
                        ),
                      ),

                      // Delete icon only shows once an image is selected
                      if (_profileImage != null)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: _deleteImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return completesetup();
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

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF138048),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
