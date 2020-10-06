import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

SettingsAcc settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return SettingsAcc.fromJson(jsonData);
}

String settingsToJson(SettingsAcc data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class SettingsAcc {
  String settingsId;

  SettingsAcc({
    this.settingsId,
  });

  factory SettingsAcc.fromJson(Map<String, dynamic> json) => new SettingsAcc(
        settingsId: json["settingsId"],
      );

  Map<String, dynamic> toJson() => {
        "settingsId": settingsId,
      };

  factory SettingsAcc.fromDocument(DocumentSnapshot doc) {
    return SettingsAcc.fromJson(doc.data());
  }
}
