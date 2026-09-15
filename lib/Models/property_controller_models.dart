class PropertyTypeOption {
  final String code;
  final String label;

  const PropertyTypeOption({required this.code, required this.label});

  factory PropertyTypeOption.fromJson(Map<String, dynamic> json) =>
      PropertyTypeOption(
        code: json["code"] as String? ?? "",
        label: json["label"] as String? ?? "",
      );
}

class SearchSuggestions {
  final List<String> properties;
  final List<String> locations;

  const SearchSuggestions({required this.properties, required this.locations});

  factory SearchSuggestions.fromJson(Map<String, dynamic> json) =>
      SearchSuggestions(
        properties: (json["properties"] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList(),
        locations: (json["locations"] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList(),
      );
}

class AmenityOption {
  final String code;
  final String label;

  const AmenityOption({required this.code, required this.label});

  factory AmenityOption.fromJson(Map<String, dynamic> json) => AmenityOption(
    code: json["code"] as String? ?? "",
    label: json["label"] as String? ?? "",
  );
}

class AmenityCatalog {
  final String category;
  final String label;
  final List<AmenityOption> options;

  const AmenityCatalog({
    required this.category,
    required this.label,
    required this.options,
  });

  factory AmenityCatalog.fromJson(Map<String, dynamic> json) => AmenityCatalog(
    category: json["category"] as String? ?? "",
    label: json["label"] as String? ?? "",
    options: (json["options"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(AmenityOption.fromJson)
        .toList(),
  );
}
