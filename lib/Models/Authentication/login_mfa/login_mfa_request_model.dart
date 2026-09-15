// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

LoginMfaRequest loginMfaRequestFromJson(String str) =>
    LoginMfaRequest.fromJson(json.decode(str));

String loginMfaRequestToJson(LoginMfaRequest data) =>
    json.encode(data.toJson());

class LoginMfaRequest {
  final String mfaToken;
  final String code;

  LoginMfaRequest({required this.mfaToken, required this.code});

  factory LoginMfaRequest.fromJson(Map<String, dynamic> json) =>
      LoginMfaRequest(mfaToken: json["mfaToken"], code: json["code"]);

  Map<String, dynamic> toJson() => {"mfaToken": mfaToken, "code": code};
}
