import 'package:flutter/material.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/ui/widgets/loading.dart';
import 'package:flutter/scheduler.dart';

class ProfileScreen extends StatefulWidget {
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StateModel appState;
  final appTitle = 'Map';
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
      final logo = Hero(
        tag: 'hero',
        child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 60.0,
            child: ClipOval(
              child: Image.asset(
                'assets/images/default.png',
                fit: BoxFit.cover,
                width: 120.0,
                height: 120.0,
              ),
            )),
      );

      final signOutButton = Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          onPressed: () {
            StateWidget.of(context).logOutUser();
          },
          padding: EdgeInsets.all(12),
          color: Theme.of(context).primaryColor,
          child: Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
      );

//check for null https://stackoverflow.com/questions/49775261/check-null-in-ternary-operation
      // final userId = appState?.firebaseUserAuth?.uid ?? '';
      final email = appState?.firebaseUserAuth?.email ?? '';
      final firstName = appState?.user?.firstName ?? '';
      final lastName = appState?.user?.lastName ?? '';
      //final settingsId = appState?.settings?.settingsId ?? '';
      //final userIdLabel = Text('App Id: ');
      final emailLabel = Text('Email: ');
      final firstNameLabel = Text('First Name: ');
      final lastNameLabel = Text('Last Name: ');
      //final settingsIdLabel = Text('SetttingsId: ');

      return Scaffold(
          appBar: new AppBar(
            title: new Text("Profile"),
          ),
          backgroundColor: Colors.white,
          body: LoadingScreen(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        logo,
                        SizedBox(height: 48.0),
                        /* userIdLabel,
                        Text(userId,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),*/
                        emailLabel,
                        Text(email,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),
                        firstNameLabel,
                        Text(firstName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),
                        lastNameLabel,
                        Text(lastName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),
                        /*settingsIdLabel,
                        Text(settingsId,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),*/
                        signOutButton
                      ],
                    ),
                  ),
                ),
              ),
              inAsyncCall: _loadingVisible),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Profile'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Map'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    Navigator.pop(context);
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed('/h');
                    });
                  },
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushReplacementNamed('/profile');
                    });
                  },
                ),
              ],
            ),
          ));
    }
  }
}
