import 'package:cyclista/main.dart';
import 'package:cyclista/ui/widgets/OSMAPIService.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

enum _MapSource {
  GIS,
  OSM,
  MAPSURFER,
  MAPBOX,
}

const kApiKey = MyApp.ACCESS_TOKEN;

class _MapSourceConfig {
  final String mapUrl;
  final List<String> domains;

  const _MapSourceConfig(this.mapUrl, this.domains);
}

final Map<_MapSource, _MapSourceConfig> _mapConfigs = {
  _MapSource.OSM: const _MapSourceConfig(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', ['a', 'b', 'c']),
  _MapSource.MAPSURFER: const _MapSourceConfig(
      'https://api.openrouteservice.org/mapsurfer/{z}/{x}/{y}.png?api_key=5b3ce3597851110001cf624849022eaf5d9e4a98a0c1b8141ec791bc',
      []),
  _MapSource.MAPBOX: const _MapSourceConfig(
      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=' +
          kApiKey,
      []),
};

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  _MapSource _currentSource;
  LatLng _position;
  MapController _mapController;
  List<LatLng> _route = [];
  Marker _user;
  Marker _from;
  Marker _to;
  int _clickTimes = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Location location = new Location();

  @override
  void initState() {
    super.initState();
    _route = [];
    _currentSource = _MapSource.MAPBOX;
    _position = new LatLng(14.599512, 120.984222);
    _mapController = new MapController();
    StreamSubscription<Map<String, double>> sub =
        location.onLocationChanged().listen((data) {});

    sub.onData((Map<String, double> pos) {
      LatLng user = new LatLng(pos['latitude'], pos['longitude']);

      setState(() {
        _user = buildMarker(user, Icons.person_pin_circle, Colors.blueAccent);
        _mapController.move(user, 14.0);
        sub.cancel();
      });
    });
  }

  void loadRoute() {
    if (_to == null || _from == null) {
      return;
    }
    LatLng from = _from.point;
    LatLng to = _to.point;
    String fromStr = '${from.longitude.toString()},${from.latitude.toString()}';
    String toStr = '${to.longitude.toString()},${to.latitude.toString()}';
    String coords = '$fromStr|$toStr';

    print(from);
    print(to);

    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text('Route calculation, please wait...'),
    ));
    OSMAPIService.getInstance().request('GET', '/directions', params: {
      'profile': 'driving-car',
      'geometry_format': 'polyline',
      'coordinates': coords,
    }).then((data) {
      if (data != null &&
          !data['routes'].isEmpty &&
          !data['routes'][0]['geometry'].isEmpty) {
        _scaffoldKey.currentState.hideCurrentSnackBar();
        setState(() {
          _route.clear();
          data['routes'][0]['geometry'].forEach((item) {
            if (item is List) {
              _route.add(new LatLng(item[1], item[0]));
            }
          });
        });
      } else {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: Text('No routes were found'),
          duration: Duration(seconds: 3),
        ));
      }
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Text('Error occured, try again later'),
        duration: Duration(seconds: 3),
      ));
      print(err);
    });
  }

  Marker buildMarker(LatLng pos, IconData icon, Color color,
      [double size = 50.0]) {
    return new Marker(
      width: 80.0,
      height: 80.0,
      point: pos,
      builder: (context) => new Icon(icon, color: color, size: size),
    );
  }

  void onMapTap(LatLng pos) {
    if (_clickTimes % 2 == 0) {
      setState(() {
        _from = buildMarker(pos, Icons.pin_drop, Colors.purple, 40.0);
        _route = [];
        _to = null;
        _clickTimes = (_clickTimes + 1) % 2;
      });
    } else {
      setState(() {
        _to = buildMarker(pos, Icons.pin_drop, Colors.green, 40.0);
        _clickTimes = (_clickTimes + 1) % 2;
        loadRoute();
      });
    }
  }

  void selectMap(_MapSource src) {
    setState(() {
      _currentSource = src;
    });
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

      final _MapSourceConfig config = _mapConfigs[_currentSource];
      final List<Marker> markers = [];

      if (_user != null) {
        markers.add(_user);
      }
      if (_from != null) {
        markers.add(_from);
      }
      if (_to != null) {
        markers.add(_to);
      }

      return Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text("Home - Map"),
          ),
          backgroundColor: Colors.white,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: new FlutterMap(
                    mapController: _mapController,
                    options: new MapOptions(
                      center: _position,
                      zoom: 25.0,
                      onTap: onMapTap,
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: config.mapUrl,
                        subdomains: config.domains,
                      ),
                      new PolylineLayerOptions(
                        polylines: [
                          new Polyline(
                            points: _route,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      new MarkerLayerOptions(markers: markers),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    FlatButton(
                      color: _currentSource == _MapSource.OSM
                          ? Colors.blueGrey
                          : Colors.grey,
                      child: Text('OpenStreetMap'),
                      onPressed: () => selectMap(_MapSource.OSM),
                    ),
                    // FlatButton(
                    //   color: _currentSource == _MapSource.MAPSURFER ? Colors.blueGrey : Colors.grey,
                    //   child: Text('Map surfer'),
                    //   onPressed: () => selectMap(_MapSource.MAPSURFER),
                    // ),
                    FlatButton(
                      color: _currentSource == _MapSource.MAPBOX
                          ? Colors.blueGrey
                          : Colors.grey,
                      child: Text('Mapbox'),
                      onPressed: () => selectMap(_MapSource.MAPBOX),
                    ),
                  ],
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
