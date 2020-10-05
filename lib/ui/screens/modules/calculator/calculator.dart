import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:flutter/material.dart';
import 'package:cyclista/models/state.dart';

class CalculatorScreen extends StatefulWidget {
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  StateModel appState;
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;

    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }
    }
  }
}
