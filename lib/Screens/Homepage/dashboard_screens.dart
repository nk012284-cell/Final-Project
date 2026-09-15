import 'package:flutter/material.dart';
import 'package:mobil_app_project/models/news_model.dart';
import 'package:mobil_app_project/models/notification_model.dart';
import 'package:mobil_app_project/models/property_model.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';
import 'package:mobil_app_project/Screens/Homepage/property_widgets.dart';
import 'package:mobil_app_project/Screens/Homepage/property_detail.dart';

const _green = Color(0xFF138048);

class HomeV2Screen extends StatefulWidget {
  const HomeV2Screen({super.key});

  @override
  State<HomeV2Screen> createState() => _HomeV2ScreenState();
}

class _HomeV2ScreenState extends State<HomeV2Screen> {
  final ApiServices _api = ApiServices(NetworkClient());
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _type = 'HOUSE';
  List<PropertyResponse> _properties = [];
  List<PropertyResponse> _newDevelopments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _findProperties();
    _loadNewDevelopments();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _findProperties() async {
    setState(() => _loading = true);
    try {
      final response = await _api.searchProperties({
        if (_locationController.text.trim().isNotEmpty)
          'q': _locationController.text.trim(),
        'type': _type,
        if (double.tryParse(_priceController.text.trim()) != null)
          'maxPrice': double.parse(_priceController.text.trim()),
        'page': 0,
        'size': 20,
      });
      if (!mounted || response.statusCode != 200) return;
      if (response.data is Map<String, dynamic>) {
        setState(() {
          _properties = PropertyPage.fromJson(response.data).items;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to find properties')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadNewDevelopments() async {
    try {
      final response = await _api.newDevelopments(size: 10);
      if (!mounted || response.statusCode != 200 || response.data is! Map) {
        return;
      }
      setState(() {
        _newDevelopments = PropertyPage.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ).items;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Home V2', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Find your next home',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _field(_locationController, 'Location', Icons.location_on_outlined),
          const SizedBox(height: 10),
          _field(
            _priceController,
            'Max price',
            Icons.payments_outlined,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: _decoration('Property type', Icons.home_work_outlined),
            items: const [
              DropdownMenuItem(value: 'HOUSE', child: Text('House')),
              DropdownMenuItem(value: 'APARTMENT', child: Text('Apartment')),
              DropdownMenuItem(value: 'VILLA', child: Text('Villa')),
              DropdownMenuItem(value: 'LAND', child: Text('Land')),
              DropdownMenuItem(value: 'HOTEL', child: Text('Hotel')),
            ],
            onChanged: (value) => setState(() => _type = value ?? 'HOUSE'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _findProperties,
              style: ElevatedButton.styleFrom(backgroundColor: _green),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Find Now'),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Our Recommendation',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (!_loading && _properties.isEmpty)
            const Text(
              'No properties found',
              style: TextStyle(color: Colors.grey),
            ),
          ..._properties.map(
            (property) => PropertyListCard(
              property: property,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(
                    propertyId: property.id,
                    initialProperty: property,
                  ),
                ),
              ),
            ),
          ),
          if (_newDevelopments.isNotEmpty) ...[
            const SizedBox(height: 26),
            const Text(
              'New Developments',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ..._newDevelopments.map(
              (property) => PropertyListCard(
                property: property,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailScreen(
                      propertyId: property.id,
                      initialProperty: property,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _decoration(hint, icon),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: const Color(0xFFF7F8FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) => PropertyFeedScreen(
    title: 'Recommendation',
    grid: false,
    loader: (api) => api.recommendedProperties(),
  );
}

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({super.key});

  @override
  Widget build(BuildContext context) => PropertyFeedScreen(
    title: 'Featured',
    grid: true,
    loader: (api) => api.featuredProperties(),
  );
}

typedef PropertyLoader = Future<dynamic> Function(ApiServices api);

class PropertyFeedScreen extends StatefulWidget {
  final String title;
  final bool grid;
  final PropertyLoader loader;

  const PropertyFeedScreen({
    super.key,
    required this.title,
    required this.grid,
    required this.loader,
  });

  @override
  State<PropertyFeedScreen> createState() => _PropertyFeedScreenState();
}

class _PropertyFeedScreenState extends State<PropertyFeedScreen> {
  final ApiServices _api = ApiServices(NetworkClient());
  List<PropertyResponse> _properties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await widget.loader(_api);
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          mounted) {
        setState(
          () => _properties = PropertyPage.fromJson(response.data).items,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : RefreshIndicator(
              onRefresh: _load,
              child: widget.grid
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _properties.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .72,
                          ),
                      itemBuilder: (_, index) => PropertyGridCard(
                        property: _properties[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: _properties[index].id,
                              initialProperty: _properties[index],
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _properties.length,
                      itemBuilder: (_, index) => PropertyListCard(
                        property: _properties[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: _properties[index].id,
                              initialProperty: _properties[index],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiServices _api = ApiServices(NetworkClient());
  List<NewsResponse> _news = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await _api.news(size: 20);
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          mounted) {
        setState(() => _news = NewsPage.fromJson(response.data).items);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('News', style: TextStyle(color: Colors.black)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _news.length,
              itemBuilder: (_, index) {
                final item = _news[index];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(news: item),
                    ),
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PropertyImage(
                          imageUrl: item.imageUrl ?? 'assets/images/fourth.png',
                          height: 170,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.readMinutes} mins read',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final NewsResponse news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('News', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PropertyImage(
            imageUrl: news.imageUrl ?? 'assets/images/fourth.png',
            height: 220,
          ),
          const SizedBox(height: 16),
          Text(
            news.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${news.readMinutes} mins read',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          Text(
            news.body ?? news.excerpt ?? '',
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final ApiServices _api = ApiServices(NetworkClient());
  List<NotificationResponse> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await _api.notifications(size: 30);
      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          mounted) {
        setState(() => _items = NotificationPage.fromJson(response.data).items);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await _api.markAllNotificationsRead();
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Read all', style: TextStyle(color: _green)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const Divider(height: 20),
              itemBuilder: (_, index) {
                final item = _items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: item.read
                        ? Colors.grey.shade200
                        : const Color(0xFFE8F5E9),
                    child: const Icon(Icons.notifications_none, color: _green),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    item.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: item.read
                      ? null
                      : () async {
                          await _api.markNotificationRead(item.id);
                          _load();
                        },
                );
              },
            ),
    );
  }
}
