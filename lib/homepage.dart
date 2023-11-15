import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps/arrow.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  Marker? currentLocationMarker;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final location = Location();
    try {
      final userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        currentLocationMarker = createMarker('My Location',
            LatLng(userLocation.latitude!, userLocation.longitude!));
        // Clear existing polylines and add a new one
        _polylines.clear();
        _addPolyline(LatLng(userLocation.latitude!, userLocation.longitude!),
            LatLng(13.1159, 77.6247));
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Marker createMarker(String id, LatLng location) {
    return Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: id),
    );
  }

  void _addPolyline(LatLng from, LatLng to) {
    _polylines.add(
      Polyline(
        polylineId: PolylineId("path_to_reva_university"),
        color: Colors.blue,
        width: 4,
        points: [from, to],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              if (currentLocationMarker != null) {
                mapController
                    .showMarkerInfoWindow(currentLocationMarker!.markerId);
              }
            },
            markers: Set.of(
                currentLocationMarker != null ? [currentLocationMarker!] : []),
            polylines: _polylines,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (currentLocation != null) {
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                            zoom: 14,
                          ),
                        ),
                      );
                    }
                  },
                  heroTag: null,
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => arrow(),
                      ),
                    );
                    // Handle the action for the 3D box icon
                    // You can add navigation to REVA University here.
                  },
                  heroTag: null,
                  child: Icon(Icons.camera_outdoor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
