import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobil_app_project/models/account_settings_models.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  static const Color primaryGreen = Color(0xFF0C8A43);

  // Map to maintain toggle state for each setting
  final Map<String, bool> _notificationSettings = {
    'Notifications': true,
    'Sound': false,
    'Vibrate': false,
    'Special Offers': false,
    'Payments': false,
    'Cashback': false,
    'App Updates': false,
  };
  final ApiServices _api = ApiServices(NetworkClient());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await _api.notificationPreferences();
      if (!mounted || response.statusCode != 200) return;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final preferences = NotificationPreferencesResponse.fromJson(data);
        setState(() {
          _notificationSettings.addAll({
            'Notifications': preferences.notifications,
            'Sound': preferences.sound,
            'Vibrate': preferences.vibrate,
            'Special Offers': preferences.specialOffers,
            'Payments': preferences.payments,
            'Cashback': preferences.cashback,
            'App Updates': preferences.appUpdates,
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    final previousValue = _notificationSettings[key] ?? false;
    setState(() {
      _notificationSettings[key] = value;
    });

    final apiKey = {
      'Notifications': 'notifications',
      'Sound': 'sound',
      'Vibrate': 'vibrate',
      'Special Offers': 'specialOffers',
      'Payments': 'payments',
      'Cashback': 'cashback',
      'App Updates': 'appUpdates',
    }[key];

    if (apiKey == null) return;

    try {
      final response = await _api.updateNotificationPreferences({
        apiKey: value,
      });
      if (!mounted || response.statusCode == 200) return;
      setState(() {
        _notificationSettings[key] = previousValue;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationSettings[key] = previousValue;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsKeys = _notificationSettings.keys.toList();

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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading) const LinearProgressIndicator(minHeight: 2),
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settingsKeys.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade200,
                    height: 20,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final key = settingsKeys[index];
                    final isEnabled = _notificationSettings[key] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            key,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.85,
                            child: CupertinoSwitch(
                              value: isEnabled,
                              activeTrackColor: primaryGreen,
                              inactiveTrackColor: Colors.grey.shade200,
                              onChanged: (bool value) =>
                                  _updatePreference(key, value),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
