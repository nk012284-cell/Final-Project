// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) =>
    VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) =>
    json.encode(data.toJson());

class VerifyOtpResponse {
  final String resetTicket;
  final int expiresInSeconds;

  VerifyOtpResponse({
    required this.resetTicket,
    required this.expiresInSeconds,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        resetTicket: json["resetTicket"],
        expiresInSeconds: json["expiresInSeconds"],
      );

  Map<String, dynamic> toJson() => {
    "resetTicket": resetTicket,
    "expiresInSeconds": expiresInSeconds,
  };
}
