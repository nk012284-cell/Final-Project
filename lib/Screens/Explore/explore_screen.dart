import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/Homepage/property_widgets.dart';
import 'package:mobil_app_project/Screens/Homepage/property_detail.dart';
import 'package:mobil_app_project/models/property_model.dart';
import 'package:mobil_app_project/models/property_controller_models.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';

const _exploreGreen = Color(0xFF138048);

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiServices _api = ApiServices(NetworkClient());
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  List<PropertyResponse> _results = [];
  bool _loading = false;
  bool _showSuggestions = false;
  String? _selectedType;
  double? _maxPrice;
  List<PropertyTypeOption> _propertyTypes = [];
  List<AmenityCatalog> _amenityCatalog = [];
  List<String> _selectedAmenities = [];
  SearchSuggestions _suggestions = const SearchSuggestions(
    properties: [],
    locations: [],
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPropertyTypes();
    _loadAmenities();
    _search();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showSuggestions = _searchController.text.trim().isNotEmpty;
    });
    if (_searchController.text.trim().length >= 2) {
      _loadSuggestions(_searchController.text.trim());
    }
  }

  Future<void> _loadPropertyTypes() async {
    try {
      final response = await _api.propertyTypes();
      if (!mounted || response.statusCode != 200 || response.data is! List) {
        return;
      }
      setState(() {
        _propertyTypes = (response.data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(PropertyTypeOption.fromJson)
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final response = await _api.propertySuggestions(query: query);
      if (!mounted || response.statusCode != 200 || response.data is! Map) {
        return;
      }
      setState(() {
        _suggestions = SearchSuggestions.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      });
    } catch (_) {}
  }

  Future<void> _loadAmenities() async {
    try {
      final response = await _api.propertyAmenities();
      if (!mounted || response.statusCode != 200 || response.data is! List) {
        return;
      }
      setState(() {
        _amenityCatalog = (response.data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(AmenityCatalog.fromJson)
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _search({String? query}) async {
    final value = (query ?? _searchController.text).trim();
    if (value.isNotEmpty && !_recentSearches.contains(value)) {
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _showSuggestions = false;
    });

    try {
      final response = await _api.searchProperties({
        if (value.isNotEmpty) 'q': value,
        if (_selectedType != null) 'type': _selectedType,
        if (_maxPrice != null) 'maxPrice': _maxPrice,
        if (_selectedAmenities.isNotEmpty) 'amenities': _selectedAmenities,
        'page': 0,
        'size': 20,
      });
      if (!mounted) return;
      if (response.statusCode != 200) {
        final data = response.data;
        final message = data is Map<String, dynamic>
            ? data['message']?.toString()
            : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message ?? 'Unable to load homes (${response.statusCode})',
            ),
          ),
        );
        return;
      }
      if (response.data is Map<String, dynamic>) {
        final results = PropertyPage.fromJson(response.data).items;
        if (results.isNotEmpty || value.isNotEmpty || _selectedType != null) {
          setState(() {
            _results = results;
          });
        } else {
          await _loadHomeFallbacks();
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to search properties')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadHomeFallbacks() async {
    final responses = await Future.wait([
      _api.recommendedProperties(size: 20),
      _api.featuredProperties(size: 20),
    ]);
    if (!mounted) return;

    final homes = <PropertyResponse>[];
    for (final response in responses) {
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        homes.addAll(PropertyPage.fromJson(response.data).items);
      }
    }

    final uniqueHomes = <int, PropertyResponse>{
      for (final home in homes) home.id: home,
    };
    setState(() {
      _results = uniqueHomes.values.toList();
    });
  }

  Future<void> _showFilters() async {
    String? type = _selectedType;
    double? maxPrice = _maxPrice;
    final selectedAmenities = [..._selectedAmenities];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: _decoration(
                  'Property type',
                  Icons.home_work_outlined,
                ),
                items:
                    (_propertyTypes.isEmpty
                            ? const [
                                PropertyTypeOption(
                                  code: 'HOUSE',
                                  label: 'House',
                                ),
                                PropertyTypeOption(
                                  code: 'APARTMENT',
                                  label: 'Apartment',
                                ),
                                PropertyTypeOption(
                                  code: 'VILLA',
                                  label: 'Villa',
                                ),
                                PropertyTypeOption(code: 'LAND', label: 'Land'),
                                PropertyTypeOption(
                                  code: 'HOTEL',
                                  label: 'Hotel',
                                ),
                              ]
                            : _propertyTypes)
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.code,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setSheetState(() => type = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: _decoration(
                  'Maximum price',
                  Icons.payments_outlined,
                ),
                onChanged: (value) => maxPrice = double.tryParse(value),
              ),
              if (_amenityCatalog.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Amenities',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 6,
                  children: _amenityCatalog
                      .expand((catalog) => catalog.options)
                      .map(
                        (amenity) => FilterChip(
                          label: Text(amenity.label),
                          selected: selectedAmenities.contains(amenity.code),
                          onSelected: (selected) => setSheetState(() {
                            if (selected) {
                              selectedAmenities.add(amenity.code);
                            } else {
                              selectedAmenities.remove(amenity.code);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _exploreGreen,
                  ),
                  onPressed: () {
                    _selectedType = type;
                    _maxPrice = maxPrice;
                    _selectedAmenities = selectedAmenities;
                    Navigator.pop(context);
                    _search();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Explore', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _search(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        decoration: _decoration(
                          'Search apart, hotel, etc.',
                          Icons.search,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilters,
                      icon: const Icon(Icons.tune, color: _exploreGreen),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F5E9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const LinearProgressIndicator(color: _exploreGreen),
                if (!_loading && _results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        'Search properties to explore',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ..._results.map(
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
            ),
          ),
          if (_showSuggestions) _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.search, color: _exploreGreen),
              title: Text(_searchController.text),
              onTap: () => _search(),
            ),
            ..._suggestions.locations.map(
              (location) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                ),
                title: Text(location),
                onTap: () {
                  _searchController.text = location;
                  _search();
                },
              ),
            ),
            ..._suggestions.properties.map(
              (property) => ListTile(
                dense: true,
                leading: const Icon(Icons.home_outlined, color: Colors.grey),
                title: Text(property),
                onTap: () {
                  _searchController.text = property;
                  _search();
                },
              ),
            ),
            ..._recentSearches.map(
              (term) => ListTile(
                dense: true,
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(term),
                trailing: const Icon(Icons.north_west, size: 16),
                onTap: () {
                  _searchController.text = term;
                  _search();
                },
              ),
            ),
          ],
        ),
      ),
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
