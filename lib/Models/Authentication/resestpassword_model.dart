// To parse this JSON data, do
//
//     final pokedex = pokedexFromJson(jsonString);

import 'dart:convert';

ResetPassword resetPasswordFromJson(String str) =>
    ResetPassword.fromJson(json.decode(str));

String resetPasswordToJson(ResetPassword data) => json.encode(data.toJson());

class ResetPassword {
  final String resetTicket;
  final String newPassword;

  ResetPassword({required this.resetTicket, required this.newPassword});

  factory ResetPassword.fromJson(Map<String, dynamic> json) => ResetPassword(
    resetTicket: json["resetTicket"],
    newPassword: json["newPassword"],
  );

  Map<String, dynamic> toJson() => {
    "resetTicket": resetTicket,
    "newPassword": newPassword,
  };
}
