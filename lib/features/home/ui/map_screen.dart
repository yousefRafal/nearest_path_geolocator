import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/features/home/data/address.dart'
    show Address;
import 'package:test_geolocator_android/features/home/data/repos/dirction_service.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = Routes.mapScreen;
  final int fileId;

  const MapScreen({required this.fileId, Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final OptimizedRouteService _routeService;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _routeService = OptimizedRouteService('');
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _routeService.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      // _optimizeRoute();
    } catch (e) {
      setState(() {
        _currentPosition = const LatLng(24.7136, 46.6753); // Default position
      });
      // _optimizeRoute();
    }
  }

  Future<void> _optimizeRoute(List<Address> addresses) async {
    if (addresses.isEmpty) return;

    setState(() => _isLoading = true);
    _markers.clear();
    _polylines.clear();

    try {
      final addressStrings = addresses.map((a) => a.fullAddress).toList();

      // استخدام العنوان الحالي كنقطة بداية
      final startAddress =
          _currentPosition != null
              ? '${_currentPosition!.latitude},${_currentPosition!.longitude}'
              : '24.7136,46.6753'; // Default Riyadh coordinates

      final response = await _routeService.getOptimizedRouteFromAddresses(
        startAddress: startAddress,
        destinationAddresses: addressStrings,
        mode: TravelMode.driving,
      );

      if (response != null && mounted) {
        _updateMapWithOptimizedRoute(response, addresses);

        // طباعة ترتيب العناوين الأمثل
        if (kDebugMode) {
          print('Optimal route order:');
        }
        response.waypointOrder.asMap().forEach((i, idx) {
          if (kDebugMode) {
            print('${i + 1}. ${addresses[idx].fullAddress}');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to optimize route: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddressDialog(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تفاصيل العنوان'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.fullAddress),
                const SizedBox(height: 10),
                Text('العنوان: ${address.postalCode}'),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('إغلاق'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'إجراء',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  void _updateMapWithOptimizedRoute(
    RouteResponse response,
    List<Address> addresses,
  ) {
    // 1. Create markers
    final newMarkers = <Marker>{};

    // Add current location marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add destination markers in optimized order
    for (var i = 0; i < response.waypointOrder.length; i++) {
      final idx = response.waypointOrder[i];
      final address = addresses[idx];
      final leg = response.legs[i];

      newMarkers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: leg.startLocation,
          infoWindow: InfoWindow(
            title: 'Stop ${i + 1}',
            snippet: address.fullAddress,
          ),
          onTap: () {
            _showAddressDialog(context, address);
          },
        ),
      );
    }

    // 2. Create polyline
    final polyline = Polyline(
      polylineId: const PolylineId('optimized_route'),
      points: response.polylinePoints,
      color: Colors.blue,
      width: 5,
      geodesic: true,
    );

    // 3. Update state
    setState(() {
      _markers.addAll(newMarkers);
      _polylines.add(polyline);
    });

    // 4. Adjust camera view
    _zoomToRoute(response.polylinePoints);
  }

  void _zoomToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = await _mapController.future;
      final bounds = _boundsFromLatLngList(points);
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressFileLoaded) {
          _optimizeRoute(state.addresses); // هنا يتم الاستدعاء
        }
      },
      builder: (context, state) {
        if (state is FilesLoaded) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? const LatLng(24.7136, 46.6753),
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (state is AddressError) {
          return Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
