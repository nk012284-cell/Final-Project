import 'package:flutter/material.dart';
import 'package:mobil_app_project/Screens/Homepage/property_widgets.dart';
import 'package:mobil_app_project/models/property_model.dart';
import 'package:mobil_app_project/network/apiservices.dart';
import 'package:mobil_app_project/network/networkclient.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  final PropertyResponse? initialProperty;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.initialProperty,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiServices _api = ApiServices(NetworkClient());
  PropertyResponse? _property;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _property = widget.initialProperty;
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final response = await _api.propertyById(widget.propertyId);
      if (mounted && response.statusCode == 200 && response.data is Map) {
        setState(() {
          _property = PropertyResponse.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = _property;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Property Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _loading && property == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF138048)),
            )
          : property == null
          ? const Center(child: Text('Property could not be loaded'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PropertyImage(
                  imageUrl: property.imageUrls.isEmpty
                      ? 'assets/images/final.png'
                      : property.imageUrls.first,
                  height: 230,
                ),
                const SizedBox(height: 16),
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  property.locationLabel,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                Text(
                  '${property.currency} ${property.price.toStringAsFixed(0)} ${property.pricePeriod}',
                  style: const TextStyle(
                    color: Color(0xFF138048),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 18,
                  children: [
                    Text('${property.beds} Beds'),
                    Text('${property.baths} Baths'),
                    if (property.areaSqft != null)
                      Text('${property.areaSqft} sqft'),
                    if (property.rating != null)
                      Text('Rating ${property.rating}'),
                  ],
                ),
                if (property.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'About this property',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description!,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
                if (property.amenities.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...property.amenities.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${entry.key}: ${entry.value.join(', ')}'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
