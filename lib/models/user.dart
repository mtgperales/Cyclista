import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

UserAcc userFromJson(String str) {
  final jsonData = json.decode(str);
  return UserAcc.fromJson(jsonData);
}

String userToJson(UserAcc data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserAcc {
  String userId;
  String firstName;
  String lastName;
  String birthDate;
  String email;
  String phoneNumber;
  String gender;

  UserAcc({
    this.userId,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.email,
    this.phoneNumber,
    this.gender,
  });

  factory UserAcc.fromJson(Map<String, dynamic> json) => new UserAcc(
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        birthDate: json["birthDate"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "birthDate": birthDate,
        "email": email,
        "phoneNumber": phoneNumber,
        "gender": gender,
      };

  factory UserAcc.fromDocument(DocumentSnapshot doc) {
    return UserAcc.fromJson(doc.data());
  }
}
