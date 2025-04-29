// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:test_geolocator_android/features/home/data/data_source/database_service.dart';
import 'package:test_geolocator_android/features/home/data/repos/dirction_service.dart';

class TestTcpOptimzation {
  static const String _geocodingApiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  final String apiKey;

  final http.Client _client;

  final _routeCache = <String, RouteResponse>{};

  DatabaseHelper databaseHelper = DatabaseHelper();
  Timer? _debounceTimer;
  TestTcpOptimzation(this.apiKey, {http.Client? clent})
    : _client = clent = clent ?? http.Client();

  Future<RouteResult?> optimizeAndDrawRoute({
    required String startAddress,
    required List<String> destinationAddresses,
    TravelMode mode = TravelMode.driving,
    double simplificationTolerance = 0.001,
  }) async {
    try {
      // (1) here you can set defualt location
      // تحويل العناوين إلى إحداثيات
      final startPoint = await _geocodeAddress(
        'رقم 255، المونسية، الرياض 13246، السعودية',
      );
      if (startPoint == null) return null;

      final destPoints = await Future.wait(
        destinationAddresses.map((a) => _geocodeAddress(a)),
      ).then((points) => points.whereType<LatLng>().toList());

      if (destPoints.isEmpty) return null;

      // حساب المسار الأمثل
      final optimizedRoute = _optimizeRoute(
        destPoints,
        startPoint,
        mode,
        simplificationTolerance,
      );
      final Set<Marker> markers = {};
      final Set<Polyline> polylines = {};
      final Set<Polygon> polygons = {};

      for (var i = 0; i < optimizedRoute.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId('dest_$i'),
            position: optimizedRoute[i],
            infoWindow: InfoWindow(title: 'الموقع ${i + 1}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
      polylines.add(
        Polyline(
          polylineId: const PolylineId('optimized_route'),
          points: optimizedRoute,
          color: Colors.blue,
          width: 4,
          geodesic: true,
        ),
      );

      final areaPoints = _computeConvexHull([startPoint, ...optimizedRoute]);
      polygons.add(
        Polygon(
          polygonId: const PolygonId('coverage_area'),
          points: areaPoints,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
          strokeWidth: 2,
        ),
      );

      // Update map view
      // _zoomToRoute(optimizedRoute);
      return RouteResult(
        markers: markers,
        optimizedRoute: optimizedRoute,
        polygons: polygons,
        polylines: polylines,
      );
    } catch (e) {
      throw Exception('Failed to optimize route from addresses: $e');
    }
  }

  List<LatLng> _optimizeRoute(
    List<LatLng> points,
    LatLng? startPoint,
    TravelMode mode,
    double simplificationTolerance,
  ) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {});
    if (points.isEmpty) return [];

    final optimizedRoute = <LatLng>[];
    final unvisited = List<LatLng>.from(points);

    // Start with user location or first point
    LatLng current = startPoint ?? unvisited.removeAt(0);
    optimizedRoute.add(current);

    while (unvisited.isNotEmpty) {
      // Find nearest unvisited point
      var nearestIndex = 0;
      var nearestDistance = _calculateDistance(current, unvisited[0]);

      for (var i = 1; i < unvisited.length; i++) {
        final distance = _calculateDistance(current, unvisited[i]);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }

      current = unvisited.removeAt(nearestIndex);
      optimizedRoute.add(current);
    }

    return optimizedRoute;
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    final cacheKey = 'geocode_${address.hashCode}';
    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey]!.legs.first.startLocation;
    }

    try {
      final response = await _client.get(
        Uri.parse(
          '$_geocodingApiUrl?address=${Uri.encodeComponent(address)}&key=$apiKey',
        ),
      );

      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);

        // تخزين في الكاش للإستخدام اللاحق
        _routeCache[cacheKey] = RouteResponse(
          polylinePoints: [],
          waypointOrder: [],
          legs: [
            RouteLeg(
              startLocation: latLng,
              endLocation: latLng,
              distance: 0,
              duration: 0,
            ),
          ],
        );

        return latLng;
      }
    } catch (e) {
      print('Geocoding error for address $address: $e');
    }
    return null;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double R = 6371e3; // Earth radius in meters
    final double lat1Rad = p1.latitude * math.pi / 180;
    final double lat2Rad = p2.latitude * math.pi / 180;
    final double deltaLatRad = (p2.latitude - p1.latitude) * math.pi / 180;
    final double deltaLonRad = (p2.longitude - p1.longitude) * math.pi / 180;

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  List<LatLng> _computeConvexHull(List<LatLng> points) {
    if (points.length < 3) return points;

    // Find the point with the lowest y-coordinate
    points.sort((a, b) => a.latitude.compareTo(b.latitude));
    final pivot = points[0];

    // Sort by polar angle with pivot
    points.sort((a, b) {
      final angleA = math.atan2(
        a.latitude - pivot.latitude,
        a.longitude - pivot.longitude,
      );
      final angleB = math.atan2(
        b.latitude - pivot.latitude,
        b.longitude - pivot.longitude,
      );
      return angleA.compareTo(angleB);
    });

    final hull = <LatLng>[];
    for (var point in points) {
      while (hull.length >= 2 &&
          _cross(hull[hull.length - 2], hull.last, point) <= 0) {
        hull.removeLast();
      }
      hull.add(point);
    }

    return hull;
  }

  // Future<void> _zoomToRoute(List<LatLng> route) async {
  //   if (route.isEmpty) return;

  //   final bounds = _boundsFromLatLngList(route);
  //   await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  // }

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.latitude - o.latitude) * (b.longitude - o.longitude) -
        (a.longitude - o.longitude) * (b.latitude - o.latitude);
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

  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}

class RouteResult {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  List<LatLng> optimizedRoute;
  RouteResult({
    required this.markers,
    required this.polygons,
    required this.optimizedRoute,
    required this.polylines,
  });

  RouteResult copyWith({
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    List<LatLng>? optimizedRoute,
  }) {
    return RouteResult(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
      optimizedRoute: optimizedRoute ?? this.optimizedRoute,
    );
  }
}
