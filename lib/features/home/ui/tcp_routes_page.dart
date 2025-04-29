import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/repos/dirction_service.dart';
import 'package:test_geolocator_android/features/home/data/repos/test_tcp_optimzation.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';

class TcpRoutesPage extends StatefulWidget {
  static const String routeName = Routes.tcpRoutes;
  final int fileId;
  const TcpRoutesPage({super.key, required this.fileId});

  @override
  State<TcpRoutesPage> createState() => _TcpRoutesPageState();
}

class _TcpRoutesPageState extends State<TcpRoutesPage> {
  late final TestTcpOptimzation _routeService;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  final Set<Polygon> _polygons = {};

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _routeService = TestTcpOptimzation('yah');
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

      final response = await _routeService.optimizeAndDrawRoute(
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

  void _updateMapWithOptimizedRoute(
    RouteResult response,
    List<Address> addresses,
  ) {
    // 1. Create markers

    // Add current location marker

    // Add destination markers in optimized order

    // 2. Create polyline

    // 3. Update state
    setState(() {
      _markers.addAll(response.markers);
      _polylines.add(response.polylines.first);
      _polygons.add(response.polygons.first);
    });

    // 4. Adjust camera view
    _zoomToRoute(response.optimizedRoute);
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
    return Scaffold(
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressFileLoaded) {
            _optimizeRoute(state.addresses); // هنا يتم الاستدعاء
          }
        },
        builder: (context, state) {
          if (state is AddressFileLoaded) {
            return Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) async {
                    print('--------------print is full ');
                    _mapController.complete(controller);

                    _optimizeRoute(state.addresses);
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194),
                    zoom: 12,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  polygons: _polygons,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
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
      ),
    );
  }
}
