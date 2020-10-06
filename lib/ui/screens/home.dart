import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cyclista/models/state.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;

  String _platformVersion = 'Unknown';
  String _instruction = "";
  final _origin =
      WayPoint(name: "Way Point 1", latitude: 14.59616, longitude: 120.99056);
  final _stop1 =
      WayPoint(name: "Way Point 2", latitude: 14.59651, longitude: 120.98956);
  final _stop2 =
      WayPoint(name: "Way Point 3", latitude: 14.59019, longitude: 120.98573);
  final _stop3 =
      WayPoint(name: "Way Point 4", latitude: 14.58992, longitude: 120.98318);

  MapBoxNavigation _directions;
  MapBoxOptions _options;

  bool _arrived = false;
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        initialLatitude: 14.59616,
        initialLongitude: 120.99056,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        animateBuildRoute: true,
        longPressDestinationEnabled: true,
        language: "en");

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
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

      return Scaffold(
          appBar: new AppBar(
            title: new Text("Home"),
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Column(children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /*SizedBox(
                        height: 10,
                      ),
                      Text('Running on: $_platformVersion\n'),*/
                      Container(
                        color: Colors.grey,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: (Text(
                            "Full Screen Navigation",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            child: Text("Start A to B"),
                            onPressed: () async {
                              var wayPoints = List<WayPoint>();
                              wayPoints.add(_origin);
                              wayPoints.add(_stop1);

                              await _directions.startNavigation(
                                  wayPoints: wayPoints,
                                  options: MapBoxOptions(
                                      mode: MapBoxNavigationMode
                                          .drivingWithTraffic,
                                      simulateRoute: true,
                                      language: "en",
                                      units: VoiceUnits.metric));
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RaisedButton(
                            child: Text("Start Multi Stop"),
                            onPressed: () async {
                              _isMultipleStop = true;
                              var wayPoints = List<WayPoint>();
                              wayPoints.add(_origin);
                              wayPoints.add(_stop1);
                              wayPoints.add(_stop2);
                              wayPoints.add(_stop3);
                              wayPoints.add(_origin);

                              await _directions.startNavigation(
                                  wayPoints: wayPoints,
                                  options: MapBoxOptions(
                                      mode: MapBoxNavigationMode.driving,
                                      simulateRoute: true,
                                      language: "en",
                                      allowsUTurnAtWayPoints: true,
                                      units: VoiceUnits.metric));
                            },
                          )
                        ],
                      ),
                      Container(
                        color: Colors.grey,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: (Text(
                            "Embedded Navigation",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            child: Text(_routeBuilt && !_isNavigating
                                ? "Clear Route"
                                : "Build Route"),
                            onPressed: _isNavigating
                                ? null
                                : () {
                                    if (_routeBuilt) {
                                      _controller.clearRoute();
                                    } else {
                                      var wayPoints = List<WayPoint>();
                                      wayPoints.add(_origin);
                                      wayPoints.add(_stop1);
                                      wayPoints.add(_stop2);
                                      wayPoints.add(_stop3);
                                      wayPoints.add(_origin);
                                      _isMultipleStop = wayPoints.length > 2;
                                      _controller.buildRoute(
                                          wayPoints: wayPoints);
                                    }
                                  },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RaisedButton(
                            child: Text("Start "),
                            onPressed: _routeBuilt && !_isNavigating
                                ? () {
                                    _controller.startNavigation();
                                  }
                                : null,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RaisedButton(
                            child: Text("Cancel "),
                            onPressed: _isNavigating
                                ? () {
                                    _controller.finishNavigation();
                                  }
                                : null,
                          )
                        ],
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Long-Press Embedded Map to Set Destination",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: (Text(
                            _instruction == null || _instruction.isEmpty
                                ? "Banner Instruction Here"
                                : _instruction,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20, top: 20, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text("Duration Remaining: "),
                                Text(_durationRemaining != null
                                    ? "${(_durationRemaining / 60).toStringAsFixed(0)} minutes"
                                    : "---")
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text("Distance Remaining: "),
                                Text(_distanceRemaining != null
                                    ? "${(_distanceRemaining * 0.000621371).toStringAsFixed(1)} miles"
                                    : "---")
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider()
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey,
                  child: MapBoxNavigationView(
                      options: _options,
                      onRouteEvent: _onEmbeddedRouteEvent,
                      onCreated:
                          (MapBoxNavigationViewController controller) async {
                        _controller = controller;
                        controller.initialize();
                      }),
                ),
              )
            ]),
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
