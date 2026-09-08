import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/AccountSettings/aboutapp.dart';
import 'package:mobil_app_project/Screens/AccountSettings/accountsecurity.dart';
import 'package:mobil_app_project/Screens/AccountSettings/helpcenter.dart';
import 'package:mobil_app_project/Screens/AccountSettings/languages.dart';
import 'package:mobil_app_project/Screens/AccountSettings/notifications.dart';
import 'package:mobil_app_project/Screens/AccountSettings/paymentaccount.dart';
import 'package:mobil_app_project/Screens/AccountSettings/privacyandpolicy.dart';
import 'package:mobil_app_project/Screens/AccountSettings/termsandcondition.dart';

import 'personaldata.dart';

class Myaccount extends StatefulWidget {
  const Myaccount({super.key});

  @override
  State<Myaccount> createState() => _MyaccountState();
}

class _MyaccountState extends State<Myaccount> {
  int selectedNavIndex = 3;

  // Selected profile image tracks either local file path or network/asset
  String? currentProfileImagePath;
  String currentProfileImageUrl = 'assets/images/profile.png';

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSectionLabel('Personal Info'),
            _buildTile(
              icon: Icons.person_outline,
              title: 'Personal Data',
              onTap: () async {
                // Personaldata screen se image path result receive karna
                final result = await Navigator.push<Map<String, String?>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Personaldata(
                      initialImagePath: currentProfileImagePath,
                      initialImageUrl: currentProfileImagePath == null
                          ? currentProfileImageUrl
                          : null,
                    ),
                  ),
                );

                // Agar image edit ya remove hui ho to state update karna
                if (result != null && mounted) {
                  setState(() {
                    currentProfileImagePath = result['filePath'];
                    if (result['imageUrl'] != null) {
                      currentProfileImageUrl = result['imageUrl']!;
                    }
                  });
                }
              },
            ),
            _buildTile(
              icon: Icons.credit_card_outlined,
              title: 'Payment Account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Paymentaccount()),
                );
              },
            ),
            _buildTile(
              icon: Icons.shield_outlined,
              title: 'Account Security',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Accountsecurity();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('General'),
            _buildTile(
              icon: Icons.language,
              title: 'Language',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return languages();
                    },
                  ),
                );
              },
            ),
            _buildTile(
              icon: Icons.notifications_none,
              title: 'Push Notification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return const Notifications();
                    },
                  ),
                );
              },
            ),
            _buildTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              trailingText: '88 MB',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('About'),
            _buildTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Helpcenter();
                    },
                  ),
                );
              },
            ),
            _buildTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Privacyandpolicy();
                    },
                  ),
                );
              },
            ),
            _buildTile(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Aboutapp();
                    },
                  ),
                );
              },
            ),
            _buildTile(
              icon: Icons.description_outlined,
              title: 'Term & Condition',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Termsandcondition();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------- Profile Header ----------------
  Widget _buildProfileHeader() {
    ImageProvider avatarImage;
    if (currentProfileImagePath != null) {
      avatarImage = FileImage(File(currentProfileImagePath!));
    } else if (currentProfileImageUrl.startsWith('assets/')) {
      avatarImage = AssetImage(currentProfileImageUrl);
    } else {
      avatarImage = NetworkImage(currentProfileImageUrl);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE0E0E0),
          backgroundImage: avatarImage,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Aaron Ramsdale',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'aaronramsdale@gmail.com',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              )
            else
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SizedBox(
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.home_outlined, 'Home', 0),
                      _buildNavIcon(Icons.explore_outlined, 'Explore', 1),
                    ],
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.chat_bubble_outline, 'Messages', 2),
                      _buildNavIcon(Icons.person, 'Profile', 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => setState(() => selectedNavIndex = 4),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, int index) {
    final bool isSelected = selectedNavIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: isSelected ? primaryGreen : Colors.grey),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isSelected ? primaryGreen : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
