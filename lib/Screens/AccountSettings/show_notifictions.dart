import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  static const Color primaryGreen = Color(0xFF138048);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: const [
          // ================= TODAY =================

          _SectionTitle(title: 'Today'),

          SizedBox(height: 8),

          NotificationTile(
            time: '08:25 AM',
            imagePath: 'assets/images/profile.png',
          ),

          NotificationTile(
            time: '08:25 AM',
            icon: Icons.celebration_outlined,
          ),

          NotificationTile(
            time: '08:23 AM',
            imagePath: 'assets/images/profile.png',
          ),

          SizedBox(height: 18),

          // ================= YESTERDAY =================

          _SectionTitle(title: 'Yesterday'),

          SizedBox(height: 8),

          NotificationTile(
            time: '08:25 AM',
            imagePath: 'assets/images/profile.png',
          ),

          NotificationTile(
            time: '08:23 AM',
            icon: Icons.notifications_none,
          ),

          NotificationTile(
            time: '08:20 AM',
            imagePath: 'assets/images/profile.png',
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// ============================================================
// NOTIFICATION TILE
// ============================================================

class NotificationTile extends StatelessWidget {
  final String time;
  final String? imagePath;
  final IconData? icon;

  const NotificationTile({
    super.key,
    required this.time,
    this.imagePath,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // PROFILE IMAGE / ICON
          // ==================================================

          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7F0),
              shape: BoxShape.circle,
            ),
            child: imagePath != null
                ? ClipOval(
                    child: Image.asset(
                      imagePath!,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,

                      // If image does not exist
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF138048),
                          size: 22,
                        );
                      },
                    ),
                  )
                : Icon(
                    icon ?? Icons.notifications_none,
                    color: const Color(0xFF138048),
                    size: 20,
                  ),
          ),

          const SizedBox(width: 12),

          // ==================================================
          // NOTIFICATION INFORMATION
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE + TIME
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // DESCRIPTION
                const Text(
                  'Lorem ipsum dolor sit amet consectetur. '
                  'Faucibus viverra ante amet elementum '
                  'pretium. Sapien id lobortis venenatis.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}