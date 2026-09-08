import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/AccountSettings/myaccount.dart';

class Homev1 extends StatefulWidget {
  const Homev1({super.key});

  @override
  State<Homev1> createState() => _Homev1State();
}

class _Homev1State extends State<Homev1> {
  int selectedCategoryIndex = 0;
  int selectedNavIndex = 0;

  final List<String> categories = ['Popular', 'Houses', 'Apartment', 'Villa'];

  // Sample data - replace with your actual model/API data
  final List<Map<String, dynamic>> featuredProperties = [
    {
      'title': 'The Lakefront Estate',
      'location': 'Lake Geneva, Switzerland',
      'price': '\$1,320.00',
      'beds': 6,
      'baths': 6,
      'imageUrl': 'assets/images/final.png', // Placeholder image path
    },
    {
      'title': 'The Emerald Residence',
      'location': 'Beverly Hills',
      'price': '\$980.00',
      'beds': 6,
      'baths': 4,
      'imageUrl': 'assets/images/second.png', // Placeholder image path
    },
  ];

  final List<Map<String, dynamic>> recommendedProperties = [
    {
      'title': 'Modern Villa',
      'location': 'Downtown',
      'price': '\$750.00',
      'tag': 'Houses',
      'liked': true,
      'imageUrl': 'assets/images/third.png', // Placeholder image path
    },
    {
      'title': 'Cozy Apartment',
      'location': 'City Center',
      'price': '\$540.00',
      'tag': 'Apartment',
      'liked': false,
      'imageUrl': 'assets/images/fourth.png', // Placeholder image path
    },
  ];

  final List<Map<String, dynamic>> propertyNews = [
    {
      'headline': "'Incredible': Awe-inspiring bayside home ticks every box",
      'readTime': '3 mins read',
      'imageUrl': 'assets/images/fourth.png', // Replace with your image path
    },
    {
      'headline': "'Old Labor Club' warehouse to smash suburb record",
      'readTime': '3 mins read',
      'imageUrl': 'assets/images/fourth.png', // Replace with your image path
    },
  ];

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildSectionHeader('Featured Property'),
            const SizedBox(height: 20),
            _buildFeaturedList(),
            const SizedBox(height: 20),
            _buildSectionHeader('Our Recomendation'),
            const SizedBox(height: 20),
            _buildRecommendationList(),
            const SizedBox(height: 20),
            _buildNewsList(), // space above bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------- AppBar ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your Location',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Row(
            children: const [
              Icon(Icons.location_on, color: primaryGreen, size: 16),
              SizedBox(width: 4),
              Text(
                'Chicago, New York',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {
                // Handle notification button press
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Search Bar ----------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search apart, hotel, etc.',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---------------- Category Chips ----------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => selectedCategoryIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryGreen.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? primaryGreen : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Section Header ----------------
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Text(
            'See All',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Featured Property List ----------------
  Widget _buildFeaturedList() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: featuredProperties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final property = featuredProperties[index];
          return _FeaturedCard(
            title: property['title'],
            location: property['location'],
            price: property['price'],
            beds: property['beds'],
            baths: property['baths'],
            imageUrl: property['imageUrl'],
          );
        },
      ),
    );
  }

  // ---------------- Recommendation List ----------------
  Widget _buildRecommendationList() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: recommendedProperties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final property = recommendedProperties[index];
          return _RecommendationCard(
            title: property['title'],
            location: property['location'],
            price: property['price'],
            tag: property['tag'],
            liked: property['liked'],
            imageurl: property['imageUrl'],
          );
        },
      ),
    );
  }

  // ---------------- News List ----------------
  Widget _buildNewsList() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: propertyNews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final news = propertyNews[index];
          return _NewsCard(
            headline: news['headline'],
            readTime: news['readTime'],
            imageUrl: news['imageUrl'],
          );
        },
      ),
    );
  }

  // ---------------- Bottom Navigation ----------------
  // ---------------- Bottom Navigation ----------------
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
                // Left side: 2 icons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.home_outlined, 0),
                      _buildNavIcon(Icons.explore_outlined, 1),
                    ],
                  ),
                ),
                // Reserved gap for the floating center button
                const SizedBox(width: 56),
                // Right side: 2 icons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.chat_bubble_outline, 2),
                      _buildNavIcon(Icons.person_outline, 3),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating green center button — now truly centered with the gap
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

  // Helper for a nav icon button with selected-state color
  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedNavIndex == index ? primaryGreen : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          selectedNavIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Myaccount();
            },
          ),
        );
      },
    );
  }
}

// ---------------- Featured Card Widget ----------------
class _FeaturedCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final int beds;
  final int baths;
  final String imageUrl; // Placeholder for image URL

  const _FeaturedCard({
    required this.title,
    required this.location,
    required this.price,
    required this.beds,
    required this.baths,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for property image - replace with Image.network(url) or Image.asset(path)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                    const Text(
                      '/month',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.bed, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      '$beds Beds',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.bathtub_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$baths Baths',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Recommendation Card Widget ----------------
class _RecommendationCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String tag;
  final bool liked;
  final String imageurl;

  const _RecommendationCard({
    required this.title,
    required this.location,
    required this.price,
    required this.tag,
    required this.liked,
    required this.imageurl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  imageurl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 9)),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: liked ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
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

// ---------------- News Card Widget ----------------
class _NewsCard extends StatelessWidget {
  final String headline;
  final String readTime;
  final String imageUrl;

  const _NewsCard({
    required this.headline,
    required this.readTime,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            readTime,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
