// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

VerifyOtpRequest verifyOtpRequestFromJson(String str) =>
    VerifyOtpRequest.fromJson(json.decode(str));

String verifyOtpRequestToJson(VerifyOtpRequest data) =>
    json.encode(data.toJson());

class VerifyOtpRequest {
  final String email;
  final String code;

  VerifyOtpRequest({required this.email, required this.code});

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      VerifyOtpRequest(email: json["email"], code: json["code"]);

  Map<String, dynamic> toJson() => {"email": email, "code": code};
}
