import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:test_geolocator_android/features/home/data/address.dart';

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
    : _client = clent ?? http.Client();

  /// نقطة: تحسين المسار باستخدام 2-Opt بعد Nearest Neighbor
  Future<RouteResult?> optimizeAndDrawRoute({
    required String startAddress,
    required List<Address> destinationAddresses,
    double simplificationTolerance = 0.001,
  }) async {
    try {
      // Geocode العنوان الأول (نقطة البداية)
      final startPoint = await _geocodeAddress(
        Address(
          fullAddress:
              '7464 محمد البرقي، المونسية، RUME3324، 3324، الرياض 13246، المملكة العربية السعودية',
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
      if (startPoint == null) return null;

      // Geocode لباقي العناوين
      final destPoints = await Future.wait(
        destinationAddresses.map((a) => _geocodeAddress(a)),
      ).then((points) => points.whereType<LatLng>().toList());

      if (destPoints.isEmpty) return null;

      // بناء القائمة الشاملة للنقاط (نقطة البداية + الوجهات)
      final allPoints = [startPoint, ...destPoints];

      // إيجاد المسار الابتدائي (Nearest Neighbor)
      List<LatLng> route = _nearestNeighborRoute(allPoints);

      // تحسين المسار باستخدام 2-Opt
      route = _twoOpt(route);

      // إنشاء العلامات والخطوط
      final Set<Marker> markers = _createMarkers(route);
      final Set<Polyline> polylines = _createPolylines(route);
      final Set<Polygon> polygons = _createPolygon(route);

      return RouteResult(
        markers: markers,
        optimizedRoute: route,
        polygons: polygons,
        polylines: polylines,
      );
    } catch (e) {
      throw Exception('Failed to optimize route: $e');
    }
  }

  // خوارزمية Nearest Neighbor
  List<LatLng> _nearestNeighborRoute(List<LatLng> points) {
    if (points.isEmpty) return [];
    final List<LatLng> unvisited = List.from(points);
    final List<LatLng> route = [];
    LatLng current = unvisited.removeAt(0); // نقطة البداية
    route.add(current);

    while (unvisited.isNotEmpty) {
      int nearestIndex = 0;
      double nearestDistance = _calculateDistance(current, unvisited[0]);
      for (int i = 1; i < unvisited.length; i++) {
        final d = _calculateDistance(current, unvisited[i]);
        if (d < nearestDistance) {
          nearestDistance = d;
          nearestIndex = i;
        }
      }
      current = unvisited.removeAt(nearestIndex);
      route.add(current);
    }
    return route;
  }

  // خوارزمية تحسين المسار باستخدام 2-Opt
  List<LatLng> _twoOpt(List<LatLng> route) {
    bool improvement = true;
    double bestDistance = _totalRouteDistance(route);

    while (improvement) {
      improvement = false;
      for (int i = 1; i < route.length - 2; i++) {
        for (int j = i + 1; j < route.length - 1; j++) {
          List<LatLng> newRoute = List.from(route);
          newRoute.setRange(i, j + 1, route.sublist(i, j + 1).reversed);
          double newDistance = _totalRouteDistance(newRoute);
          if (newDistance < bestDistance) {
            route = newRoute;
            bestDistance = newDistance;
            improvement = true;
          }
        }
      }
    }
    return route;
  }

  double _totalRouteDistance(List<LatLng> route) {
    double total = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      total += _calculateDistance(route[i], route[i + 1]);
    }
    return total;
  }

  Set<Marker> _createMarkers(List<LatLng> points) {
    final Set<Marker> markers = {};
    for (int i = 0; i < points.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: points[i],
          onTap: () {
            print('النقطة ${i + 1}');
          },
          infoWindow: InfoWindow(
            title: i == 0 ? 'نقطة البداية' : 'نقطة ${i + 1}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _createPolylines(List<LatLng> points) {
    return {
      Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 4,
        geodesic: true, // خط جغرافي وليس مستقيم تمامًا
      ),
    };
  }

  Set<Polygon> _createPolygon(List<LatLng> points) {
    // يمكنك استخدام convex hull أو فقط رسم مضلع يحيط بجميع النقاط
    if (points.length < 3) return {};
    final hull = _computeConvexHull(points);
    return {
      Polygon(
        polygonId: PolygonId('hull'),
        points: hull,
        strokeColor: Colors.green,
        fillColor: Colors.green.withOpacity(0.1),
        strokeWidth: 2,
      ),
    };
  }

  Future<LatLng?> _geocodeAddress(Address address) async {
    final cacheKey = 'geocode_${address.fullAddress.hashCode}_ar_sa';
    final cachedResponse = _routeCache[cacheKey];
    if (cachedResponse != null && cachedResponse.legs.isNotEmpty) {
      return cachedResponse.legs.first.startLocation;
    }

    try {
      final uri = Uri.parse(
        '$_geocodingApiUrl?'
        'address=${Uri.encodeComponent(address.fullAddress)}'
        '&key=$apiKey'
        '&language=ar'
        '&region=sa'
        '&components=country:SA',
      );

      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Geocoding request timed out');
            },
          );

      if (response.statusCode != 200) {
        throw HttpException(
          'Request failed with status ${response.statusCode}',
        );
      }

      final data = json.decode(response.body);

      if (data['status'] != 'OK' || data['results'].isEmpty) {
        throw GeocodingException(data['status'] ?? 'UNKNOWN_ERROR');
      }

      final result = data['results'][0];
      final location = result['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      final updatedAddress = address.copyWith(
        lat: latLng.latitude,
        lng: latLng.longitude,
        city: _extractAddressComponent(result, 'locality'),
        country: _extractAddressComponent(result, 'country'),
        district: _extractAddressComponent(result, 'sublocality'),
        postalCode: _extractAddressComponent(result, 'postal_code'),
      );

      unawaited(
        databaseHelper
            .updateAddress(updatedAddress)
            .catchError((e) => debugPrint('Database update failed: $e')),
      );

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
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      throw NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      throw NetworkException('Request timed out');
    } on HttpException catch (e) {
      debugPrint('HTTP error: $e');
      throw GeocodingException('Server error occurred');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  String _extractAddressComponent(Map<String, dynamic> result, String type) {
    try {
      final components = result['address_components'] as List;
      final component = components.firstWhere(
        (c) => (c['types'] as List).contains(type),
        orElse: () => null,
      );
      return component?['long_name'] ?? '';
    } catch (e) {
      debugPrint('Error extracting $type: $e');
      return '';
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double R = 6371e3; // meters
    final double lat1Rad = p1.latitude * math.pi / 180;
    final double lat2Rad = p2.latitude * math.pi / 180;
    final double deltaLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final double deltaLon = (p2.longitude - p1.longitude) * math.pi / 180;

    final double a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  List<LatLng> _computeConvexHull(List<LatLng> points) {
    if (points.length < 3) return points;

    points.sort((a, b) => a.latitude.compareTo(b.latitude));
    final pivot = points[0];

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

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.latitude - o.latitude) * (b.longitude - o.longitude) -
        (a.longitude - o.longitude) * (b.latitude - o.latitude);
  }

  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}

// باقي الكلاسات الاستثنائية كما هي
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

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class GeocodingException implements Exception {
  final String status;
  GeocodingException(this.status);
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
}
