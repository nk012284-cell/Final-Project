import 'dart:convert';

JwtResponse jwtResponseFromJson(String source) =>
    JwtResponse.fromJson(json.decode(source) as Map<String, dynamic>);

String jwtResponseToJson(JwtResponse data) => json.encode(data.toJson());

class JwtResponse {
  final String token;
  final String tokenType;
  final int expiresInSeconds;
  final String refreshToken;
  final int refreshExpiresInSeconds;

  const JwtResponse({
    required this.token,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.refreshToken,
    required this.refreshExpiresInSeconds,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) => JwtResponse(
    token: json["token"] as String,
    tokenType: json["tokenType"] as String,
    expiresInSeconds: (json["expiresInSeconds"] as num).toInt(),
    refreshToken: json["refreshToken"] as String,
    refreshExpiresInSeconds: (json["refreshExpiresInSeconds"] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "tokenType": tokenType,
    "expiresInSeconds": expiresInSeconds,
    "refreshToken": refreshToken,
    "refreshExpiresInSeconds": refreshExpiresInSeconds,
  };
}
