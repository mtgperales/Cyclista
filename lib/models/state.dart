import 'package:firebase_auth/firebase_auth.dart';
import 'package:cyclista/models/user.dart';
import 'package:cyclista/models/settings.dart';

class StateModel {
  bool isLoading;
  User firebaseUserAuth;
  UserAcc user;
  SettingsAcc settings;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
  });
}
