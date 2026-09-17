import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mobil_app_project/Screens/Homepage/property_detail.dart';
import 'package:mobil_app_project/screens/AccountSettings/aboutapp.dart';
import 'package:mobil_app_project/screens/AccountSettings/accountsecurity.dart';
import 'package:mobil_app_project/screens/AccountSettings/helpcenter.dart';
import 'package:mobil_app_project/screens/AccountSettings/languages.dart';
import 'package:mobil_app_project/screens/AccountSettings/notifications.dart';
import 'package:mobil_app_project/screens/AccountSettings/paymentaccount.dart';
import 'package:mobil_app_project/screens/AccountSettings/privacyandpolicy.dart';
import 'package:mobil_app_project/screens/AccountSettings/termsandcondition.dart';

import 'package:mobil_app_project/models/user_profile_model.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';

import 'personaldata.dart';

class Myaccount extends StatefulWidget {
  const Myaccount({super.key});

  @override
  State<Myaccount> createState() => _MyaccountState();
}

class _MyaccountState extends State<Myaccount> {
  int selectedNavIndex = 3;

  // ============================================================
  // PROFILE DATA
  // ============================================================

  String? currentProfileImagePath;

  String currentProfileImageUrl =
      'assets/images/profile.png';

  UserProfileResponse? _profile;

  final ApiServices _api =
      ApiServices(NetworkClient());

  static const Color primaryGreen =
      Color(0xFF2ECC71);

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final response =
          await _api.currentUser();

      if (!mounted ||
          response.statusCode != 200) {
        return;
      }

      final data = response.data;

      if (data is Map<String, dynamic>) {
        setState(() {
          _profile =
              UserProfileResponse.fromJson(data);

          if (_profile
                  ?.avatarUrl
                  ?.isNotEmpty ==
              true) {
            currentProfileImageUrl =
                _profile!.avatarUrl!;
          }
        });
      }
    } catch (e) {
      debugPrint(
        'Profile loading error: $e',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // PROFILE
            // ==================================================

            _buildProfileHeader(),

            const SizedBox(height: 24),

            // ==================================================
            // PERSONAL INFO
            // ==================================================

            _buildSectionLabel(
              'Personal Info',
            ),

            // ==================================================
            // PERSONAL DATA
            // ==================================================

            _buildTile(
              icon: Icons.person_outline,
              title: 'Personal Data',

              onTap: () async {
                final result =
                    await Navigator.push<
                        Map<String, String?>>(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        Personaldata(
                      initialImagePath:
                          currentProfileImagePath,

                      initialImageUrl:
                          currentProfileImagePath ==
                                  null
                              ? currentProfileImageUrl
                              : null,
                    ),
                  ),
                );

                if (result != null &&
                    mounted) {
                  setState(() {
                    currentProfileImagePath =
                        result['filePath'];

                    if (result[
                            'imageUrl'] !=
                        null) {
                      currentProfileImageUrl =
                          result[
                              'imageUrl']!;
                    }
                  });
                }
              },
            ),

            // ==================================================
            // MY PROPERTIES
            // ==================================================

            _buildTile(
              icon:
                  Icons.home_work_outlined,
              title: 'My Properties',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const PropertyDetailScreen(
                      propertyId: 1,
                    ),
                  ),
                );
              },
            ),

            // ==================================================
            // PAYMENT ACCOUNT
            // ==================================================

            _buildTile(
              icon:
                  Icons.credit_card_outlined,
              title: 'Payment Account',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const Paymentaccount(),
                  ),
                );
              },
            ),

            // ==================================================
            // ACCOUNT SECURITY
            // ==================================================

            _buildTile(
              icon:
                  Icons.shield_outlined,
              title: 'Account Security',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        Accountsecurity(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // GENERAL
            // ==================================================

            _buildSectionLabel(
              'General',
            ),

            // ==================================================
            // LANGUAGE
            // ==================================================

            _buildTile(
              icon: Icons.language,
              title: 'Language',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        languages(),
                  ),
                );
              },
            ),

            // ==================================================
            // PUSH NOTIFICATION
            // ==================================================

            _buildTile(
              icon:
                  Icons.notifications_none,
              title:
                  'Push Notification',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const Notifications(),
                  ),
                );
              },
            ),

            // ==================================================
            // CLEAR CACHE
            // ==================================================

            _buildTile(
              icon:
                  Icons.delete_outline,
              title: 'Clear Cache',
              trailingText: '88 MB',

              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Cache cleared',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ABOUT
            // ==================================================

            _buildSectionLabel(
              'About',
            ),

            // ==================================================
            // HELP CENTER
            // ==================================================

            _buildTile(
              icon:
                  Icons.help_outline,
              title: 'Help Center',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const Helpcenter(),
                  ),
                );
              },
            ),

            // ==================================================
            // PRIVACY & POLICY
            // ==================================================

            _buildTile(
              icon:
                  Icons.lock_outline,
              title:
                  'Privacy & Policy',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const Privacyandpolicy(),
                  ),
                );
              },
            ),

            // ==================================================
            // ABOUT APP
            // ==================================================

            _buildTile(
              icon:
                  Icons.info_outline,
              title: 'About App',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        Aboutapp(),
                  ),
                );
              },
            ),

            // ==================================================
            // TERMS & CONDITIONS
            // ==================================================

            _buildTile(
              icon: Icons
                  .description_outlined,
              title:
                  'Term & Condition',

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        Termsandcondition(),
                  ),
                );
              },
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          _buildBottomNav(),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    ImageProvider avatarImage;

    if (currentProfileImagePath !=
        null) {
      avatarImage = FileImage(
        File(
          currentProfileImagePath!,
        ),
      );
    } else if (currentProfileImageUrl
        .startsWith('assets/')) {
      avatarImage = AssetImage(
        currentProfileImageUrl,
      );
    } else {
      avatarImage = NetworkImage(
        currentProfileImageUrl,
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
              const Color(
            0xFFE0E0E0,
          ),
          backgroundImage:
              avatarImage,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                _profile?.fullName ??
                    _profile
                        ?.firstName ??
                    'Your profile',

                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                _profile?.email ?? '',

                style:
                    const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _buildSectionLabel(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 6.0,
      ),

      child: Text(
        title,

        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight:
              FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNT TILE
  // ============================================================

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12.0,
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  Colors.black87,
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Text(
                title,

                style:
                    const TextStyle(
                  fontSize: 14,
                  color:
                      Colors.black87,
                ),
              ),
            ),

            if (trailingText != null)
              Text(
                trailingText,

                style:
                    const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    return SizedBox(
      height: 70,

      child: Stack(
        alignment:
            Alignment.center,
        clipBehavior: Clip.none,

        children: [
          Container(
            decoration:
                BoxDecoration(
              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.grey
                      .withValues(
                    alpha: 0.15,
                  ),
                  blurRadius: 10,
                  offset:
                      const Offset(
                    0,
                    -2,
                  ),
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceAround,

                    children: [
                      _buildNavIcon(
                        Icons
                            .home_outlined,
                        'Home',
                        0,
                      ),

                      _buildNavIcon(
                        Icons
                            .explore_outlined,
                        'Explore',
                        1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 56,
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceAround,

                    children: [
                      _buildNavIcon(
                        Icons
                            .chat_bubble_outline,
                        'Messages',
                        2,
                      ),

                      _buildNavIcon(
                        Icons.person,
                        'Profile',
                        3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // CENTER BUTTON
          // ====================================================

          Positioned(
            top: -20,

            child:
                GestureDetector(
              onTap: () {
                setState(() {
                  selectedNavIndex =
                      4;
                });
              },

              child: Container(
                width: 56,
                height: 56,

                decoration:
                    BoxDecoration(
                  color:
                      primaryGreen,
                  shape:
                      BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color:
                          primaryGreen
                              .withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION ICON
  // ============================================================

  Widget _buildNavIcon(
    IconData icon,
    String label,
    int index,
  ) {
    final bool isSelected =
        selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNavIndex =
              index;
        });
      },

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 22,

            color: isSelected
                ? primaryGreen
                : Colors.grey,
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,

            style: TextStyle(
              fontSize: 9,

              color: isSelected
                  ? primaryGreen
                  : Colors.grey,

              fontWeight:
                  isSelected
                      ? FontWeight
                          .w600
                      : FontWeight
                          .normal,
            ),
          ),
        ],
      ),
    );
  }
}