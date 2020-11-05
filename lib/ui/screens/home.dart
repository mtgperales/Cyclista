import 'dart:convert';

import 'package:cyclista/main.dart';
import 'package:cyclista/ui/widgets/search.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:latlong/latlong.dart';

import 'package:mapbox_api/mapbox_api.dart' as api;
import 'package:mapbox_gl/mapbox_gl.dart' as gl;
import 'package:nominatim_location_picker/nominatim_location_picker.dart';
import 'package:location/location.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

const kApiKey = MyApp.ACCESS_TOKEN;

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //final PermissionHandler permissionHandler = PermissionHandler();
  //Map<PermissionGroup, PermissionStatus> permissions;
  //Map<Permission, PermissionStatus> permissions;

  gl.MapboxMapController mapController;
  void _onMapCreated(gl.MapboxMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    acquireCurrentLocation();
    initialize();
  }

  //SEARCH WIDGET
  Map _pickedLocation;
  Future getLocationWithNominatim() async {
    Map result = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return NominatimLocationPicker(
            searchHint: 'Search',
            awaitingForLocation: "Waiting...",
            /*customMapLayer: TileLayerOptions(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=' +
                        kApiKey,
                subdomains: []),*/
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

  //USER LOCATION
  /*Position _currentPosition;
  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }*/
  LocationData _locationData;

  Future<LatLng> acquireCurrentLocation() async {
    // Initializes the plugin and starts listening for potential platform events
    Location location = new Location();

    // Whether or not the location service is enabled
    bool serviceEnabled;

    // Status of a permission request to use location services
    PermissionStatus permissionGranted;

    // Check if the location service is enabled, and if not, then request it. In
    // case the user refuses to do it, return immediately with a null result
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check for location permissions; similar to the workflow in Android apps,
    // so check whether the permissions is granted, if not, first you need to
    // request it, and then read the result of the request, and only proceed if
    // the permission was granted by the user
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Gets the current location of the user
    _locationData = await location.getLocation();
    return LatLng(_locationData.latitude, _locationData.longitude);
  }

  //MAPBOX ROUTE
  MapBoxNavigation _directions;
  MapBoxOptions _options;

  String _instruction = "";
  bool _arrived = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //_directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
    _options = MapBoxOptions(
        initialLatitude: _locationData.latitude,
        initialLongitude: _locationData.longitude,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.cycling,
        units: VoiceUnits.metric,
        simulateRoute: false,
        animateBuildRoute: true,
        //longPressDestinationEnabled: true,
        language: "en");
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
          appBar: new AppBar(title: new Text("Home - Map"), actions: [
            IconButton(
                icon: Icon(Icons.search, size: 30),
                onPressed: () async {
                  await getLocationWithNominatim();
                })
          ]),
          backgroundColor: Colors.white,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 5),
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
                  //_getCurrentLocation();
                  print("LATITUDE");
                  print(_locationData.latitude);
                  print("LONGITUDE");
                  print(_locationData.longitude);
                  mapController.moveCamera(
                    gl.CameraUpdate.newCameraPosition(
                      gl.CameraPosition(
                        target: gl.LatLng(
                            _locationData.latitude, _locationData.longitude),
                        zoom: 15.0,
                      ),
                    ),
                  );
                },
              ),
              FloatingActionButton(
                heroTag: "test",
                child: Icon(Icons.send_sharp, size: 30),
                onPressed: () async {
                  var wayPoints = List<WayPoint>();
                  final _origin = WayPoint(
                      name: "Initial Position",
                      latitude: _locationData.latitude,
                      longitude: _locationData.longitude);
                  final _destination = WayPoint(
                      name: "Initial Position",
                      latitude: _pickedLocation['latlng'].latitude,
                      longitude: _pickedLocation['latlng'].longitude);
                  wayPoints.add(_origin);
                  wayPoints.add(_destination);

                  await _directions.startNavigation(
                      wayPoints: wayPoints,
                      options: MapBoxOptions(
                          mode: MapBoxNavigationMode.cycling,
                          simulateRoute: false,
                          allowsUTurnAtWayPoints: true,
                          language: "en",
                          voiceInstructionsEnabled: true,
                          bannerInstructionsEnabled: true,
                          isOptimized: true,
                          units: VoiceUnits.metric));
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

  Future<void> _onRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions.distanceRemaining;
    _durationRemaining = await _directions.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}
