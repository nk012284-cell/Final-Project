import 'dart:convert';

LoginMfaResponse loginMfaResponseFromJson(String str) =>
    LoginMfaResponse.fromJson(json.decode(str));

String loginMfaResponseToJson(LoginMfaResponse data) =>
    json.encode(data.toJson());

class LoginMfaResponse {
  final String token;
  final String tokenType;
  final int expiresInSeconds;
  final String refreshToken;
  final int refreshExpiresInSeconds;

  LoginMfaResponse({
    required this.token,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.refreshToken,
    required this.refreshExpiresInSeconds,
  });

  factory LoginMfaResponse.fromJson(Map<String, dynamic> json) =>
      LoginMfaResponse(
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
