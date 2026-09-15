class NewsResponse {
  final int id;
  final String slug;
  final String title;
  final String? excerpt;
  final String? body;
  final String? imageUrl;
  final int readMinutes;

  const NewsResponse({
    required this.id,
    required this.slug,
    required this.title,
    this.excerpt,
    this.body,
    this.imageUrl,
    required this.readMinutes,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) => NewsResponse(
    id: (json["id"] as num).toInt(),
    slug: json["slug"] as String? ?? "",
    title: json["title"] as String? ?? "",
    excerpt: json["excerpt"] as String?,
    body: json["body"] as String?,
    imageUrl: json["imageUrl"] as String?,
    readMinutes: (json["readMinutes"] as num?)?.toInt() ?? 0,
  );
}

class NewsPage {
  final List<NewsResponse> items;

  const NewsPage({required this.items});

  factory NewsPage.fromJson(Map<String, dynamic> json) => NewsPage(
    items: (json["items"] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(NewsResponse.fromJson)
        .toList(),
  );
}
