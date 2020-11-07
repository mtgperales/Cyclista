import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclista/util/auth.dart';
import 'package:cyclista/util/validator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/ui/widgets/loading.dart';
import 'package:firebase_picture_uploader/firebase_picture_uploader.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateScreen extends StatefulWidget {
  ProfileUpdateScreenState createState() => ProfileUpdateScreenState();
}

class ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  bool _autoValidate = false;
  final _firestore = Firestore.instance;

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = new TextEditingController();
  final TextEditingController _lastName = new TextEditingController();
  final TextEditingController _phoneNumber = new TextEditingController();
  final TextEditingController _birthDate = new TextEditingController();
  String _genderRadioBtnVal;

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

      final firstName = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: _firstName,
        validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.person,
              color: Colors.grey,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'First Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final lastName = TextFormField(
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        controller: _lastName,
        validator: Validator.validateName,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.person,
              color: Colors.grey,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Last Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final birthDate = TextFormField(
        controller: _birthDate,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.calendar_today,
              color: Colors.grey,
            ), // icon is 48px widget.
          ), // icon is 48px widget.
          hintText: 'Date of Birth',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onTap: () async {
          DateTime date = DateTime(1900);
          FocusScope.of(context).requestFocus(new FocusNode());

          date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1600),
              lastDate: DateTime(2025));
          _birthDate.text = date.toIso8601String().toString().substring(0, 10);
        },
      );

      final gender = Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: Row(
          children: <Widget>[
            Radio<String>(
              value: "Male",
              groupValue: _genderRadioBtnVal,
              onChanged: _handleGenderChange,
            ),
            Text("Male"),
            Radio<String>(
              value: "Female",
              groupValue: _genderRadioBtnVal,
              onChanged: _handleGenderChange,
            ),
            Text("Female"),
          ],
        ),
      );

      final confirmUpdate = Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          onPressed: () {
            _profileUpdate(
                firstName: _firstName.text,
                lastName: _lastName.text,
                birthDate: _birthDate.text,
                gender: _genderRadioBtnVal,
                context: context);
          },
          padding: EdgeInsets.all(12),
          color: Theme.of(context).primaryColor,
          child: Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      );

      //check for null https://stackoverflow.com/questions/49775261/check-null-in-ternary-operation
      final userId = appState?.firebaseUserAuth?.uid ?? '';
      // final email = appState?.firebaseUserAuth?.email ?? '';
      final firstNameDB = appState?.user?.firstName ?? '';
      final lastNameDB = appState?.user?.lastName ?? '';
      final genderDB = appState?.user?.gender ?? '';
      final birthDateDB = appState?.user?.birthDate ?? '';

      //final settingsId = appState?.settings?.settingsId ?? '';
      //final userIdLabel = Text('App Id: ');
      //final emailLabel = Text('Email: ');
      final firstNameDBLabel = Text('First Name: ');
      final lastNameDBLabel = Text('Last Name: ');
      final genderDBLabel = Text('Gender: ');
      final birthDateDBLabel = Text('BirthDate: ');

      //final settingsIdLabel = Text('SetttingsId: ');

      return Scaffold(
        appBar: new AppBar(
          title: new Text("Profile Update"),
        ),
        backgroundColor: Colors.white,
        body: LoadingScreen(
            //key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 48.0),
                      /* userIdLabel,
                        Text(userId,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),


                      emailLabel,
                      Text(email,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      firstNameDBLabel,
                      Text(firstNameDB,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      lastNameDBLabel,
                      Text(lastNameDB,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      genderDBLabel,
                      Text(genderDB,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      birthDateDBLabel,
                      Text(birthDateDB,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),*/
                      /*settingsIdLabel,
                        Text(settingsId,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12.0),*/

                      firstName,
                      SizedBox(height: 15.0),
                      lastName,
                      SizedBox(height: 15.0),
                      birthDate,
                      SizedBox(height: 15.0),
                      gender,
                      SizedBox(height: 8.0),
                      confirmUpdate
                    ],
                  ),
                ),
              ),
            ),
            inAsyncCall: _loadingVisible),
        /* drawer: Drawer(
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
                      //Navigator.pushReplacementNamed(context, '/h');
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
                      Navigator.of(context).pushNamed('/profile');
                      //Navigator.pushReplacementNamed(context, '/profile');
                    });
                  },
                ),
              ],
            ),
          )*/
      );
    }
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _handleGenderChange(String value) {
    setState(() {
      _genderRadioBtnVal = value;
    });
  }

  void _profileUpdate(
      {String firstName,
      String lastName,
      String phoneNumber,
      String gender,
      String email,
      String birthDate,
      BuildContext context}) async {
    // if (_formKey.currentState.validate()) {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      await _changeLoadingVisible();

      final userId = appState?.firebaseUserAuth?.uid ?? '';
      final phoneNumber = appState?.user?.phoneNumber ?? '';
      final email = appState?.user?.email ?? '';
      //final birthDateDB = appState?.user?.birthDate ?? '';

      _firestore.collection('users').doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'birthDate': birthDate,
        'phoneNumber': phoneNumber,
        'email': email,
        'userId': userId,
      });
      //await Navigator.pushReplacementNamed(context, '/profile');
      await Navigator.pop(context, true);
    } catch (e) {
      _changeLoadingVisible();
      print("Update Error: $e");
      String exception = Auth.getExceptionText(e);
      Flushbar(
        title: "Update Error",
        message: exception,
        duration: Duration(seconds: 5),
      )..show(context);
    }
    /*}else {
      setState(() => _autoValidate = true);
    }*/
  }
}
