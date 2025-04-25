import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/features/home/data/address.dart'
    show Address;
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = Routes.mapScreen;
  final int fileId;

  const MapScreen({super.key, required this.fileId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    context.read<AddressBloc>().add(LoadAddressesForFile(widget.fileId));
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });
  }

  Future<void> _optimizeRoute(List<Address> addresses) async {
    if (addresses.isEmpty) return;
    // Filter out completed addresses
    List<Address> pendingAddresses = addresses.where((a) => !a.isDone).toList();
    if (pendingAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All deliveries completed!')),
      );
      return;
    }

    // Start from current location or first pending address
    LatLng startPoint =
        currentPosition != null
            ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
            : LatLng(
              pendingAddresses.first.coordinates.lat,
              pendingAddresses.first.coordinates.lng,
            );

    // Create route starting from current position
    List<Address> route = [];
    List<Address> remaining = List.from(pendingAddresses);

    while (remaining.isNotEmpty) {
      Address? nearest;
      double minDistance = double.infinity;

      for (var address in remaining) {
        double distance = _calculateDistance(
          startPoint.latitude,
          startPoint.longitude,
          address.coordinates.lat,
          address.coordinates.lng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = address;
        }
      }

      if (nearest != null) {
        route.add(nearest);
        remaining.remove(nearest);
        startPoint = LatLng(nearest.coordinates.lat, nearest.coordinates.lng);
      }
    }

    // Create markers
    markers.clear();

    // Add current location marker if available
    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }

    // Add route markers
    markers.addAll(
      route
          .asMap()
          .map(
            (i, address) => MapEntry(
              i,
              Marker(
                markerId: MarkerId(address.id.toString()),
                position: LatLng(
                  address.coordinates.lat,
                  address.coordinates.lng,
                ),
                infoWindow: InfoWindow(
                  title:
                      'Stop ${i + 1}: ${address.addressDetails.buildingNumber}',
                  snippet: address.addressDetails.fullAddress,
                ),
                onTap: () => _showAddressActions(address),
              ),
            ),
          )
          .values,
    );

    // Create polylines
    polylines.clear();
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    // Add line from current location to first stop if available
    if (currentPosition != null && route.isNotEmpty) {
      PointLatLng start = PointLatLng(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
      PointLatLng end = PointLatLng(
        route.first.coordinates.lat,
        route.first.coordinates.lng,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: '',
        request: PolylineRequest(
          origin: start,
          destination: end,
          mode: TravelMode.driving,
          wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.addAll(
          result.points.map((point) => LatLng(point.latitude, point.longitude)),
        );
      }
    }

    // Add lines between stops
    for (int i = 0; i < route.length - 1; i++) {
      PointLatLng start = PointLatLng(
        route[i].coordinates.lat,
        route[i].coordinates.lng,
      );
      PointLatLng end = PointLatLng(
        route[i + 1].coordinates.lat,
        route[i + 1].coordinates.lng,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: '',
        request: PolylineRequest(
          origin: start,
          destination: end,
          mode: TravelMode.driving,
          wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.addAll(
          result.points.map((point) => LatLng(point.latitude, point.longitude)),
        );
      }
    }

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      ),
    );

    setState(() {});

    // Move camera to show all markers
    if (mapController != null && markers.isNotEmpty) {
      final bounds = _boundsFromLatLngList(
        markers.map((m) => m.position).toList(),
      );
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _showAddressActions(Address address) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  address.orderId,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  address.addressDetails.fullAddress,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (!address.isDone)
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddressBloc>().add(
                        MarkAddressAsDone(int.parse(address.id)),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Mark as Done'),
                  ),
              ],
            ),
          ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null || x1 == null || y0 == null || y1 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressFileLoaded) {
            _optimizeRoute(state.file.addresses);
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (state is AddressFileLoaded) {
                _optimizeRoute(state.file.addresses);
              }
            },
          );
        },
      ),
    );
  }
}
