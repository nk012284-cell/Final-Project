import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Accountsecurity extends StatefulWidget {
  const Accountsecurity({super.key});

  @override
  State<Accountsecurity> createState() => _AccountsecurityState();
}

class _AccountsecurityState extends State<Accountsecurity> {
  static const Color primaryGreen = Color(0xFF0C8A43);

  bool rememberPassword = true;
  bool faceId = true;
  bool biometricId = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Remember Password',
                      value: rememberPassword,
                      onChanged: (val) =>
                          setState(() => rememberPassword = val),
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 1,
                    ),
                    _buildSwitchRow(
                      title: 'Face ID',
                      value: faceId,
                      onChanged: (val) => setState(() => faceId = val),
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 1,
                    ),
                    _buildSwitchRow(
                      title: 'Biometric ID',
                      value: biometricId,
                      onChanged: (val) => setState(() => biometricId = val),
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 1,
                    ),
                    InkWell(
                      onTap: () {
                        // Handle Google Authenticator tap
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Google Authenticator',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Change Password action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E4EA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              activeColor: primaryGreen,
              trackColor: Colors.grey.shade200,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
