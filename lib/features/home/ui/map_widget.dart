import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_geolocator_android/features/home/ui/setting_page.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  void initState() {
    super.initState();
    // startTracking();
  }

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  void dispose() {
    super.dispose();
    stopTracking();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        SizedBox(
          height: 500,
          width: 500,
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ],
    );
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }
  print('permission: $permission');
  print(getLocationSettings().distanceFilter);
  Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
  Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
  print('destance');
  print(
    Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838),
  );

  return await Geolocator.getCurrentPosition();
}

void startTracking() {
  positionStreamSubscription = Geolocator.getPositionStream(
    locationSettings: getLocationSettings(),
  ).listen((position) {
    print('Position changed: ${position.latitude}, ${position.longitude}');
  });
}

// في مكان مناسب داخل التطبيق (ليس في main())
StreamSubscription<Position>? positionStreamSubscription;

void stopTracking() {
  positionStreamSubscription?.cancel();
  positionStreamSubscription = null;
}
