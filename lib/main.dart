import 'package:cyclista/ui/screens/modules/calculator/calculator.dart';
import 'package:cyclista/ui/screens/modules/profile/profile.dart';
import 'package:cyclista/ui/screens/modules/profile/profile_update.dart';
import 'package:cyclista/ui/screens/modules/sos/contactsPage.dart';
import 'package:cyclista/ui/screens/modules/sos/seeContactsButton.dart';
import 'package:cyclista/ui/screens/modules/sos/sos.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/theme.dart';
import 'package:cyclista/ui/screens/home.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/ui/screens/sign_up.dart';
import 'package:cyclista/ui/screens/forgot_password.dart';

class MyApp extends StatelessWidget {
  MyApp() {
    //Navigation.initPaths();
  }

  static const String ACCESS_TOKEN =
      "pk.eyJ1IjoidHJpc3RhbmdwIiwiYSI6ImNrZncwczZrejFtY3Eycm84cHBhc3UwdjQifQ.WlXj0w42j50nYLPs_tQwrw";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyclista',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,

      home: SignInScreen(),
      routes: {
        '/h': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/profile': (context) => ProfileScreen(),
        '/profile-update': (context) => ProfileUpdateScreen(),
        '/calculator': (context) => CalculatorScreen(),
        '/contacts': (context) => SeeContactsButton(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              Scaffold(body: Center(child: Text('Not Found'))),
        );
      },
    );
  }
}

void main() async {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(stateWidget);
}
