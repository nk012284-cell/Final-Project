// To parse this JSON data, do
//
//     final addnewcard = addnewcardFromJson(jsonString);

import 'dart:convert';

Addnewcard addnewcardFromJson(String str) =>
    Addnewcard.fromJson(json.decode(str));

String addnewcardToJson(Addnewcard data) => json.encode(data.toJson());

class Addnewcard {
  final String holderName;
  final String cardNumber;
  final int expMonth;
  final int expYear;
  final bool makeDefault;

  Addnewcard({
    required this.holderName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.makeDefault,
  });

  factory Addnewcard.fromJson(Map<String, dynamic> json) => Addnewcard(
    holderName: json["holderName"],
    cardNumber: json["cardNumber"],
    expMonth: json["expMonth"],
    expYear: json["expYear"],
    makeDefault: json["makeDefault"],
  );

  Map<String, dynamic> toJson() => {
    "holderName": holderName,
    "cardNumber": cardNumber,
    "expMonth": expMonth,
    "expYear": expYear,
    "makeDefault": makeDefault,
  };
}
