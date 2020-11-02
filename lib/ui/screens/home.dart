import 'dart:convert';

import 'package:cyclista/main.dart';
import 'package:cyclista/ui/widgets/api.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';

import 'package:mapbox_api/mapbox_api.dart' as api;
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox_gl;
import 'package:polyline/polyline.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart' as search_f;

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

const kApiKey = MyApp.ACCESS_TOKEN;

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  mapbox_gl.MapboxMapController mapController;
  void _onMapCreated(mapbox_gl.MapboxMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<search_f.MapBoxPlace>> getPlaces() async {
    search_f.ReverseGeoCoding reverseGeoCoding = search_f.ReverseGeoCoding(
      apiKey: kApiKey,
      limit: 5,
    );
    return await reverseGeoCoding.getAddress(search_f.Location(
        lat: 48.8584, // this is eiffel tower position
        lng: 2.2945));
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

      return Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text("Home - Map"),
          ),
          backgroundColor: Colors.white,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 5),
              FloatingActionButton(
                heroTag: "btn_search",
                child: Icon(Icons.search, size: 30),
                onPressed: () {},
              ),
              FloatingActionButton(
                heroTag: "btn_zoom_in",
                child: Icon(Icons.zoom_in, size: 30),
                onPressed: () {
                  mapController.moveCamera(
                    mapbox_gl.CameraUpdate.zoomIn(),
                  );
                },
              ),
              FloatingActionButton(
                heroTag: "btn_zoom_out",
                child: Icon(Icons.zoom_out, size: 30),
                onPressed: () {
                  mapController.moveCamera(
                    mapbox_gl.CameraUpdate.zoomOut(),
                  );
                },
              ),
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: mapbox_gl.MapboxMap(
                    accessToken: kApiKey,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    trackCameraPosition: true,
                    myLocationTrackingMode:
                        mapbox_gl.MyLocationTrackingMode.Tracking,
                    initialCameraPosition: const mapbox_gl.CameraPosition(
                        target: mapbox_gl.LatLng(14.599512, 120.984222),
                        zoom: 15.0),
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Map'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                /*ListTile(
                  title: Text('Map'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    Navigator.pop(context);
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      //Navigator.of(context).pushNamed('/h');
                      Navigator.pushReplacementNamed(context, '/h');
                    });
                  },
                ),*/
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
                ListTile(
                  title: Text('Calculator'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed('/calculator');
                      //Navigator.pushReplacementNamed(context, '/profile');
                    });
                  },
                ),
                ListTile(
                  title: Text('S.O.S'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    Navigator.pop(context);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed('/sos');
                      //Navigator.pushReplacementNamed(context, '/profile');
                    });
                  },
                ),
                ListTile(
                  title: Text('Log Out'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                    StateWidget.of(context).logOutUser();
                  },
                ),
              ],
            ),
          ));
    }
  }
}
