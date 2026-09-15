// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

RefreshRequest refreshRequestFromJson(String str) =>
    RefreshRequest.fromJson(json.decode(str));

String refreshRequestToJson(RefreshRequest data) => json.encode(data.toJson());

class RefreshRequest {
  final String refreshToken;

  RefreshRequest({required this.refreshToken});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      RefreshRequest(refreshToken: json["refreshToken"]);

  Map<String, dynamic> toJson() => {"refreshToken": refreshToken};
}
