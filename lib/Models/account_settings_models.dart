class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  factory LanguageOption.fromJson(Map<String, dynamic> json) => LanguageOption(
    code: json["code"] as String? ?? "",
    name: json["name"] as String? ?? "",
    nativeName: json["nativeName"] as String? ?? "",
  );
}

class NotificationPreferencesResponse {
  final bool notifications;
  final bool sound;
  final bool vibrate;
  final bool payments;
  final bool specialOffers;
  final bool cashback;
  final bool appUpdates;

  const NotificationPreferencesResponse({
    required this.notifications,
    required this.sound,
    required this.vibrate,
    required this.payments,
    required this.specialOffers,
    required this.cashback,
    required this.appUpdates,
  });

  factory NotificationPreferencesResponse.fromJson(Map<String, dynamic> json) =>
      NotificationPreferencesResponse(
        notifications: json["notifications"] as bool? ?? false,
        sound: json["sound"] as bool? ?? false,
        vibrate: json["vibrate"] as bool? ?? false,
        payments: json["payments"] as bool? ?? false,
        specialOffers: json["specialOffers"] as bool? ?? false,
        cashback: json["cashback"] as bool? ?? false,
        appUpdates: json["appUpdates"] as bool? ?? false,
      );
}
