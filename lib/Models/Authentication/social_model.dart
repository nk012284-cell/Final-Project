// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

Social socialFromJson(String str) => Social.fromJson(json.decode(str));

String socialToJson(Social data) => json.encode(data.toJson());

class Social {
  final String idToken;

  Social({required this.idToken});

  factory Social.fromJson(Map<String, dynamic> json) =>
      Social(idToken: json["idToken"]);

  Map<String, dynamic> toJson() => {"idToken": idToken};
}
