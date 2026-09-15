// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

Signup signupFromJson(String str) => Signup.fromJson(json.decode(str));

String signupToJson(Signup data) => json.encode(data.toJson());

class Signup {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;

  Signup({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  factory Signup.fromJson(Map<String, dynamic> json) => Signup(
    fullName: json["fullName"],
    phoneNumber: json["phoneNumber"],
    email: json["email"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "phoneNumber": phoneNumber,
    "email": email,
    "password": password,
  };
}
