import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
//import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:latlong/latlong.dart';
import 'package:cyclista/models/state.dart';
import 'package:cyclista/util/state_widget.dart';
import 'package:cyclista/ui/screens/sign_in.dart';
import 'package:cyclista/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;

  MapController mapController = MapController();
  List<Marker> markers = [];
  int pointIndex;
  List points = [
    LatLng(51.5, -0.09),
    LatLng(49.8566, 3.3522),
  ];

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

      return Scaffold(
          appBar: new AppBar(
            title: new Text("Home"),
          ),
          backgroundColor: Colors.white,
          body: new FlutterMap(
            options: new MapOptions(
                center: new LatLng(14.5995, 120.9842),
                minZoom: 14.0,
                plugins: [
                  LocationPlugin(),
                  TappablePolylineMapPlugin(),
                  //MarkerClusterPlugin(),
                ]),
            layers: [
              new TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),

              TappablePolylineLayerOptions(
                  // Will only render visible polylines, increasing performance
                  polylineCulling: true,
                  polylines: [
                    TaggedPolyline(
                      tag:
                          "My Polyline", // An optional tag to distinguish polylines in callback
                      // ...all other Polyline options
                    ),
                  ],
                  onTap: (TaggedPolyline polyline) => print(polyline.tag)),

              MarkerLayerOptions(markers: markers),
              //userLocationOptions,

              LocationOptions(
                markers: markers,
                onLocationUpdate: (LatLngData ld) {
                  print('Location updated: ${ld?.location}');
                },
                onLocationRequested: (LatLngData ld) {
                  if (ld == null || ld.location == null) {
                    return;
                  }
                  mapController?.move(ld.location, 16.0);
                },
                buttonBuilder: (BuildContext context,
                    ValueNotifier<LocationServiceStatus> status,
                    Function onPressed) {
                  return Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                      child: FloatingActionButton(
                          child: ValueListenableBuilder<LocationServiceStatus>(
                              valueListenable: status,
                              builder: (BuildContext context,
                                  LocationServiceStatus value, Widget child) {
                                switch (value) {
                                  case LocationServiceStatus.disabled:
                                  case LocationServiceStatus.permissionDenied:
                                  case LocationServiceStatus.unsubscribed:
                                    return const Icon(
                                      Icons.location_disabled,
                                      color: Colors.white,
                                    );
                                    break;
                                  default:
                                    return const Icon(
                                      Icons.location_searching,
                                      color: Colors.white,
                                    );
                                    break;
                                }
                              }),
                          onPressed: () => onPressed()),
                    ),
                  );
                },
              ),
            ],
            mapController: mapController,
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
