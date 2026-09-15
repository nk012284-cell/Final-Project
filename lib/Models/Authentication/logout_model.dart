// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

Logout logoutFromJson(String str) => Logout.fromJson(json.decode(str));

String logoutToJson(Logout data) => json.encode(data.toJson());

class Logout {
  final String refreshToken;

  Logout({required this.refreshToken});

  factory Logout.fromJson(Map<String, dynamic> json) =>
      Logout(refreshToken: json["refreshToken"]);

  Map<String, dynamic> toJson() => {"refreshToken": refreshToken};
}
