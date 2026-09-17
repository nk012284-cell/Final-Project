import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/Homepage/Add_property.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';
import 'package:mobil_app_project/utils/constants.dart';

class MyPropertity extends StatefulWidget {
  final ApiServices? apiServices;

  const MyPropertity({super.key, this.apiServices});

  @override
  State<MyPropertity> createState() => _MyPropertityState();
}

class _MyPropertityState extends State<MyPropertity> {
  static const _green = Color(0xFF087F43);
  static const _softGreen = Color(0xFFE8F4EE);

  late final ApiServices _apiServices;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<_PropertyCardData> _properties = [];
  String _selectedFilter = 'All Properties';
  bool _isLoading = true;
  String? _error;

  final _filters = const [
    'All Properties',
    'Active',
    'Pending',
    'Sold',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _apiServices = widget.apiServices ?? ApiServices(NetworkClient());
    _loadProperties();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim();
      final responses = await Future.wait(
        _statusQueries.map(
          (status) =>
              (_apiServices as dynamic).getProperties(
                status: status,
                query: query,
              ),
        ),
      );
      final rawItems = <Map<String, dynamic>>[];
      for (final response in responses) {
        if (response.statusCode == null || response.statusCode! >= 300) {
          throw Exception('Request failed with status ${response.statusCode}');
        }
        final responseBody = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        debugPrint(
          'My properties response: ${response.statusCode} $responseBody',
        );
        rawItems.addAll(_extractPropertyItems(responseBody));
      }
      final items = rawItems
          .map(_PropertyCardData.fromJson)
          .where(_matchesSelectedFilter)
          .toList();

      if (!mounted) return;
      setState(() {
        _properties = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _apiErrorMessage(error);
      });
    }
  }

  String _apiErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.contains('401')) {
      return 'Please sign in to view your properties';
    }
    if (message.contains('403')) {
      return 'You are not allowed to view properties';
    }
    return message.isEmpty ? 'Unable to load your properties' : message;
  }

  bool _matchesSelectedFilter(_PropertyCardData property) {
    if (_selectedFilter == 'All Properties') return true;
    if (_selectedFilter == 'Pending') return property.status == 'PENDING';
    if (_selectedFilter == 'Sold') return property.status == 'SOLD';
    if (_selectedFilter == 'Draft') return property.status == 'DRAFT';
    return const {
      'ACTIVE',
      'AVAILABLE',
      'FOR_SALE',
      'FOR_RENT',
      'PUBLISHED',
      'DRAFT',
    }.contains(property.status);
  }

  List<String?> get _statusQueries {
    if (_selectedFilter == 'Pending') return const ['PENDING'];
    if (_selectedFilter == 'Sold') return const ['SOLD'];
    if (_selectedFilter == 'Draft') return const ['DRAFT'];
    if (_selectedFilter == 'Active') {
      return const ['FOR_SALE', 'FOR_RENT'];
    }
    return const [null];
  }

  List<Map<String, dynamic>> _extractPropertyItems(dynamic value) {
    if (value is List) {
      return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
    if (value is! Map) return <Map<String, dynamic>>[];

    final map = Map<String, dynamic>.from(value);
    for (final key in const [
      'items',
      'content',
      'properties',
      'results',
      'data',
      'payload',
      'result',
    ]) {
      final candidate = map[key];
      final extracted = _extractPropertyItems(candidate);
      if (extracted.isNotEmpty || candidate is List) return extracted;
    }
    if (map['id'] != null ||
        map['propertyId'] != null ||
        map['title'] != null) {
      return [map];
    }
    return <Map<String, dynamic>>[];
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _loadProperties);
  }

  void _selectFilter(String filter) {
    setState(() => _selectedFilter = filter);
    _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 32,
        title: const Text(
          'My Properties',
          style: TextStyle(
            color: Color(0xFF101318),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: _softGreen,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _openAddProperty,
                icon: const Icon(Icons.add, color: _green, size: 20),
                tooltip: 'Add property',
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _green,
        onRefresh: _loadProperties,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 12, 24, 24),
          children: [
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildFilters(),
            const SizedBox(height: 14),
            if (_isLoading)
              const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator(color: _green)),
              )
            else if (_error != null)
              _buildErrorState()
            else if (_properties.isEmpty)
              _buildEmptyState()
            else
              ..._properties.map(_buildPropertyCard),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search apart, hotel, etc.',
        hintStyle: const TextStyle(color: Color(0xFF8D97A5), fontSize: 11),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF9AA8B8),
          size: 20,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  _loadProperties();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 16),
              ),
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => _selectFilter(filter),
            labelStyle: TextStyle(
              fontSize: 10,
              color: selected ? _green : const Color(0xFF8D97A5),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ), 
            backgroundColor: const Color(0xFFF5F7F9),
            selectedColor: _softGreen,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(_PropertyCardData property) {
    final statusColor = property.status == 'SOLD'
        ? const Color(0xFFE53935)
        : property.status == 'PENDING'
        ? const Color(0xFFE28A1A)
        : const Color(0xFF16A085);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E6EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: _propertyImage(property.imageUrl, property.title),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        property.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B929C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: _DashedDivider(),
          ),
          Row(
            children: [
              _detailValue('Price', property.price),
              const SizedBox(width: 35),
              _detailValue(
                'Status',
                property.statusLabel,
                valueColor: statusColor,
              ),
              const Spacer(),
              SizedBox(
                height: 25,
                child: ElevatedButton(
                  onPressed: () => _showPropertyDetails(context, property),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'See Detail',
                    style: TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailValue(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: Color(0xFF9CA5AE)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            color: valueColor ?? const Color(0xFF15191E),
          ),
        ),
      ],
    );
  }

  Widget _propertyImage(String? imageUrl, String title) {
    final fallback = _fallbackAsset(title);
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(fallback, width: 108, height: 108, fit: BoxFit.cover);
    }
    final resolvedUrl = _resolveMediaUrl(imageUrl);
    return Image.network(
      resolvedUrl,
      width: 108,
      height: 108,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.asset(fallback, width: 108, height: 108, fit: BoxFit.cover),
    );
  }

  String _resolveMediaUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = Uri.parse(Constants.baseURL);
    if (value.startsWith('/')) {
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: value,
      ).toString();
    }
    return Uri.parse('${Constants.baseURL}$value').toString();
  }

  String _fallbackAsset(String title) {
    final index = title.hashCode.abs() % 4;
    return const [
      'assets/images/final.png',
      'assets/images/second.png',
      'assets/images/third.png',
      'assets/images/fourth.png',
    ][index];
  }

  Widget _buildErrorState() =>
      _messageState('Could not load properties', 'Try again', _loadProperties);

  Widget _buildEmptyState() {
    final hasFilters =
        _selectedFilter != 'All Properties' ||
        _searchController.text.trim().isNotEmpty;
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 36,
              color: Color(0xFFB8C1CA),
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters ? 'No properties found' : 'You have no properties yet',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: hasFilters ? _clearFilters : _openAddProperty,
              child: Text(
                hasFilters ? 'Clear filters' : 'Add your first property',
                style: const TextStyle(color: _green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _selectedFilter = 'All Properties');
    _loadProperties();
  }

  Widget _messageState(String title, String action, VoidCallback onPressed) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 36,
              color: Color(0xFFB8C1CA),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(action, style: const TextStyle(color: _green)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _green,
      unselectedItemColor: const Color(0xFF9DA8B6),
      selectedFontSize: 9,
      unselectedFontSize: 9,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apartment),
          label: 'Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _openAddProperty() async {
    final propertyAdded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddProperty(apiServices: _apiServices)),
    );
    if (propertyAdded == true && mounted) {
      _loadProperties();
    }
  }

  void _showPropertyDetails(BuildContext context, _PropertyCardData property) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              property.location,
              style: const TextStyle(color: Color(0xFF7A838D)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  property.price,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 18),
                Text(
                  property.statusLabel,
                  style: const TextStyle(color: _green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 7).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => const SizedBox(
              width: 3,
              child: Divider(height: 1, color: Color(0xFFD9E0E5)),
            ),
          ),
        );
      },
    );
  }
}

class _PropertyCardData {
  final String title;
  final String location;
  final String price;
  final String status;
  final String statusLabel;
  final String? imageUrl;

  const _PropertyCardData({
    required this.title,
    required this.location,
    required this.price,
    required this.status,
    required this.statusLabel,
    this.imageUrl,
  });

  factory _PropertyCardData.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        (json['status'] ??
                json['propertyStatus'] ??
                json['listingStatus'] ??
                json['state'] ??
                'ACTIVE')
            .toString()
            .toUpperCase();
    final rawPrice =
        json['priceLabel'] ??
        json['formattedPrice'] ??
        json['price'] ??
        'Price unavailable';
    final imageUrl = _firstMediaUrl(
      json['imageUrls'] ?? json['images'] ?? json['photos'] ?? json['media'],
    );
    return _PropertyCardData(
      title: (json['title'] ?? json['name'] ?? 'Untitled property').toString(),
      location:
          (json['locationLabel'] ??
                  json['location'] ??
                  [
                    json['city'],
                    json['country'],
                  ].where((value) => value != null).join(', '))
              .toString(),
      price: rawPrice.toString(),
      status: rawStatus,
      statusLabel: _statusLabel(rawStatus),
      imageUrl: imageUrl ?? json['imageUrl']?.toString(),
    );
  }

  static String? _firstMediaUrl(dynamic media) {
    if (media is String && media.trim().isNotEmpty) return media;
    if (media is List) {
      for (final item in media) {
        final url = _firstMediaUrl(item);
        if (url != null) return url;
      }
    }
    if (media is Map) {
      for (final key in const ['url', 'imageUrl', 'fileUrl', 'src', 'path']) {
        final value = media[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return null;
  }

  static String _statusLabel(String status) {
    if (const {
      'FOR_SALE',
      'FOR_RENT',
      'AVAILABLE',
      'ACTIVE',
      'PUBLISHED',
    }.contains(status)) {
      return 'Active';
    }
    if (status == 'PENDING') {
      return 'Pending';
    }
    if (status == 'SOLD') {
      return 'Sold';
    }
    return status[0] + status.substring(1).toLowerCase();
  }
}