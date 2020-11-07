import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

UserLoc fromFromJsonLoc(String str) {
  final jsonData = json.decode(str);
  return UserLoc.fromJson(jsonData);
}

String userToJsonLoc(UserLoc data) {
  final dyn = data.toJsonLoc();
  return json.encode(dyn);
}

class UserLoc {
  String cachedLat;
  String cachedLong;

  UserLoc({this.cachedLat, this.cachedLong});

  factory UserLoc.fromJson(Map<String, dynamic> json) => new UserLoc(
        cachedLat: json["cachedLat"],
        cachedLong: json["cachedLong"],
      );

  Map<String, dynamic> toJsonLoc() => {
        "cachedLat": cachedLat,
        "cachedLong": cachedLong,
      };

  factory UserLoc.fromDocument(DocumentSnapshot doc) {
    return UserLoc.fromJson(doc.data());
  }
}
