// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

RefreshResponse refreshResponseFromJson(String str) =>
    RefreshResponse.fromJson(json.decode(str));

String refreshResponseToJson(RefreshResponse data) =>
    json.encode(data.toJson());

class RefreshResponse {
  final String token;
  final String tokenType;
  final int expiresInSeconds;
  final String refreshToken;
  final int refreshExpiresInSeconds;

  RefreshResponse({
    required this.token,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.refreshToken,
    required this.refreshExpiresInSeconds,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        token: json["token"],
        tokenType: json["tokenType"],
        expiresInSeconds: json["expiresInSeconds"],
        refreshToken: json["refreshToken"],
        refreshExpiresInSeconds: json["refreshExpiresInSeconds"],
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "tokenType": tokenType,
    "expiresInSeconds": expiresInSeconds,
    "refreshToken": refreshToken,
    "refreshExpiresInSeconds": refreshExpiresInSeconds,
  };
}
