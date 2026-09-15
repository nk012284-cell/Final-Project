class PaymentMethodResponse {
  final int id;
  final String type;
  final String? brand;
  final String? last4;
  final String? expiry;
  final String? accountLabel;
  final bool isDefault;
  final bool expired;

  const PaymentMethodResponse({
    required this.id,
    required this.type,
    this.brand,
    this.last4,
    this.expiry,
    this.accountLabel,
    required this.isDefault,
    required this.expired,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) =>
      PaymentMethodResponse(
        id: (json["id"] as num).toInt(),
        type: json["type"] as String? ?? "CARD",
        brand: json["brand"] as String?,
        last4: json["last4"] as String?,
        expiry: json["expiry"] as String?,
        accountLabel: json["accountLabel"] as String?,
        isDefault: json["isDefault"] as bool? ?? false,
        expired: json["expired"] as bool? ?? false,
      );
}

class AddCardRequest {
  final String holderName;
  final String cardNumber;
  final int expMonth;
  final int expYear;
  final bool makeDefault;

  const AddCardRequest({
    required this.holderName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    this.makeDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'holderName': holderName,
    'cardNumber': cardNumber,
    'expMonth': expMonth,
    'expYear': expYear,
    'makeDefault': makeDefault,
  };
}

class TotpStatusResponse {
  final bool enabled;
  final bool enrolmentStarted;
  final int recoveryCodesRemaining;

  const TotpStatusResponse({
    required this.enabled,
    required this.enrolmentStarted,
    required this.recoveryCodesRemaining,
  });

  factory TotpStatusResponse.fromJson(Map<String, dynamic> json) =>
      TotpStatusResponse(
        enabled: json["enabled"] as bool? ?? false,
        enrolmentStarted: json["enrolmentStarted"] as bool? ?? false,
        recoveryCodesRemaining:
            (json["recoveryCodesRemaining"] as num?)?.toInt() ?? 0,
      );
}
