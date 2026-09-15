class NotificationResponse {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final bool read;
  final DateTime? createdAt;

  const NotificationResponse({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.read,
    this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        id: (json["id"] as num).toInt(),
        title: json["title"] as String? ?? "Notification",
        body: json["body"] as String? ?? "",
        imageUrl: json["imageUrl"] as String?,
        read: json["read"] as bool? ?? false,
        createdAt: DateTime.tryParse(json["createdAt"] as String? ?? ""),
      );
}

class NotificationPage {
  final List<NotificationResponse> items;

  const NotificationPage({required this.items});

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        items: (json["items"] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(NotificationResponse.fromJson)
            .toList(),
      );
}
