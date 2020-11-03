import 'dart:convert';

import 'package:cyclista/main.dart';
import 'package:cyclista/ui/widgets/api.dart';
import 'package:cyclista/ui/widgets/location.helper.dart';
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
import 'package:latlong/latlong.dart';

import 'package:mapbox_api/mapbox_api.dart' as api;
import 'package:mapbox_gl/mapbox_gl.dart' as gl;
import 'package:nominatim_location_picker/nominatim_location_picker.dart';
import 'package:polyline/polyline.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

const kApiKey = MyApp.ACCESS_TOKEN;

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  gl.MapboxMapController mapController;
  void _onMapCreated(gl.MapboxMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  // var _pickedLocationText;

  /*Widget getLocationWithMapBox() {
    return MapBoxLocationPicker(
      popOnSelect: true,
      apiKey: kApiKey,
      limit: 10,
      language: 'en',
      country: 'ph',
      searchHint: 'Search',
      awaitingForLocation: "Waiting...",
      onSelected: (place) {
        setState(() {
          _pickedLocationText = place.geometry
              .coordinates; // Example of how to call the coordinates after using the Mapbox Location Picker

          print("coords");
          print(_pickedLocationText);
          print("below");
          print(_pickedLocationText['latlng'].latitude);
          print(_pickedLocationText['latlng'].longitude);
          mapController.moveCamera(
            gl.CameraUpdate.newCameraPosition(
              gl.CameraPosition(
                bearing: 270.0,
                target: gl.LatLng(0.0, 0.0),
                zoom: 10.0,
              ),
            ),
          );
        });
      },
      context: context,
    );
  }*/
  Map _pickedLocation;

  Future getLocationWithNominatim() async {
    Map result = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return NominatimLocationPicker(
            searchHint: 'Search',
            awaitingForLocation: "Waiting...",
          );
        });
    if (result != null) {
      setState(() => _pickedLocation = result);
      print("coordinates");
      print(_pickedLocation);
      print("latitude");
      print(_pickedLocation['latlng'].latitude);
      print("longitude");
      print(_pickedLocation['latlng'].longitude);
      mapController.moveCamera(
        gl.CameraUpdate.newCameraPosition(
          gl.CameraPosition(
            target: gl.LatLng(_pickedLocation['latlng'].latitude,
                _pickedLocation['latlng'].longitude),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      return;
    }
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
                onPressed: () async {
                  await getLocationWithNominatim();
                },
                /*onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => getLocationWithMapBox()),
                  );
                },*/
              ),
              FloatingActionButton(
                heroTag: "btn_zoom_in",
                child: Icon(Icons.zoom_in, size: 30),
                onPressed: () {
                  mapController.moveCamera(
                    gl.CameraUpdate.zoomIn(),
                  );
                },
              ),
              FloatingActionButton(
                heroTag: "btn_zoom_out",
                child: Icon(Icons.zoom_out, size: 30),
                onPressed: () {
                  mapController.moveCamera(
                    gl.CameraUpdate.zoomOut(),
                  );
                },
              ),
              FloatingActionButton(
                heroTag: "btn_gps",
                child: Icon(Icons.gps_fixed_outlined, size: 30),
                onPressed: () {
                  mapController.moveCamera(
                    gl.CameraUpdate.newCameraPosition(
                      gl.CameraPosition(
                        target: gl.LatLng(_pickedLocation['latlng'].latitude,
                            _pickedLocation['latlng'].longitude),
                        zoom: 15.0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: gl.MapboxMap(
                    accessToken: kApiKey,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    trackCameraPosition: true,
                    myLocationTrackingMode: gl.MyLocationTrackingMode.Tracking,
                    initialCameraPosition: const gl.CameraPosition(
                        target: gl.LatLng(14.599512, 120.984222), zoom: 15.0),

                    /*child: gl.MapboxMap(
                    accessToken: kApiKey,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    trackCameraPosition: true,
                    myLocationTrackingMode: gl.MyLocationTrackingMode.Tracking,
                    initialCameraPosition: const gl.CameraPosition(
                        target: gl.LatLng(14.599512, 120.984222), zoom: 15.0),
                  ),*/
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
