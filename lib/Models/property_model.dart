class PropertyResponse {
  final int id;
  final String title;
  final String locationLabel;
  final num price;
  final String currency;
  final String pricePeriod;
  final int beds;
  final int baths;
  final List<String> imageUrls;
  final String type;
  final bool isFavorite;
  final String status;
  final String? description;
  final String? priceLabel;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final int? areaSqft;
  final double? rating;
  final int? reviewCount;
  final bool featured;
  final bool newDevelopment;
  final int? yearBuilt;
  final int? floors;
  final int? landAreaSqft;
  final List<String> lifestyles;
  final Map<String, List<String>> amenities;
  final String? liveTourUrl;

  const PropertyResponse({
    required this.id,
    required this.title,
    required this.locationLabel,
    required this.price,
    required this.currency,
    required this.pricePeriod,
    required this.beds,
    required this.baths,
    required this.imageUrls,
    required this.type,
    required this.isFavorite,
    required this.status,
    this.description,
    this.priceLabel,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.areaSqft,
    this.rating,
    this.reviewCount,
    this.featured = false,
    this.newDevelopment = false,
    this.yearBuilt,
    this.floors,
    this.landAreaSqft,
    this.lifestyles = const [],
    this.amenities = const {},
    this.liveTourUrl,
  });

  factory PropertyResponse.fromJson(Map<String, dynamic> json) {
    return PropertyResponse(
      id: (json["id"] as num).toInt(),
      title: json["title"] as String? ?? "Untitled property",
      locationLabel: json["locationLabel"] as String? ?? "",
      price: json["price"] as num? ?? 0,
      currency: json["currency"] as String? ?? "",
      pricePeriod: json["pricePeriod"] as String? ?? "",
      beds: (json["beds"] as num?)?.toInt() ?? 0,
      baths: (json["baths"] as num?)?.toInt() ?? 0,
      imageUrls: (json["imageUrls"] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      type: json["type"] as String? ?? "",
      isFavorite: json["isFavorite"] as bool? ?? false,
      status: json["status"] as String? ?? "",
      description: json["description"] as String?,
      priceLabel: json["priceLabel"] as String?,
      city: json["city"] as String?,
      country: json["country"] as String?,
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      areaSqft: (json["areaSqft"] as num?)?.toInt(),
      rating: (json["rating"] as num?)?.toDouble(),
      reviewCount: (json["reviewCount"] as num?)?.toInt(),
      featured: json["featured"] as bool? ?? false,
      newDevelopment: json["newDevelopment"] as bool? ?? false,
      yearBuilt: (json["yearBuilt"] as num?)?.toInt(),
      floors: (json["floors"] as num?)?.toInt(),
      landAreaSqft: (json["landAreaSqft"] as num?)?.toInt(),
      lifestyles: (json["lifestyles"] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      amenities: _parseAmenities(json["amenities"]),
      liveTourUrl: json["liveTourUrl"] as String?,
    );
  }

  static Map<String, List<String>> _parseAmenities(dynamic value) {
    if (value is! Map<String, dynamic>) return const {};
    return value.map(
      (key, value) => MapEntry(
        key,
        value is List
            ? value
                  .map(
                    (item) => item is Map<String, dynamic>
                        ? item["label"]?.toString() ?? ""
                        : item.toString(),
                  )
                  .where((item) => item.isNotEmpty)
                  .toList()
            : <String>[],
      ),
    );
  }
}

class PropertyPage {
  final List<PropertyResponse> items;
  final bool hasNext;

  const PropertyPage({required this.items, required this.hasNext});

  factory PropertyPage.fromJson(Map<String, dynamic> json) => PropertyPage(
    items: (json["items"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PropertyResponse.fromJson)
        .toList(),
    hasNext: json["hasNext"] as bool? ?? false,
  );
}
