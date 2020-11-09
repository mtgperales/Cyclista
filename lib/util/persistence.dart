import 'package:cyclista/ui/screens/home.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => new _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isLoggedIn;
  @override
  void initState() {
    isLoggedIn = false;
    FirebaseAuth.instance.authStateChanges().listen((user) => user != null
        ? setState(() {
            isLoggedIn = true;
          })
        : null);
    super.initState();
    // new Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? new HomeScreen() : new SignInScreen();
  }
}
