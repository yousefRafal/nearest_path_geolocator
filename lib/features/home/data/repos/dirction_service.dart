import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OptimizedRouteService {
  static const String _directionsApiUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String _geocodingApiUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  final String apiKey;
  final http.Client _client;
  final _routeCache = <String, RouteResponse>{};
  Timer? _debounceTimer;

  OptimizedRouteService(this.apiKey, {http.Client? client})
    : _client = client ?? http.Client();

  Future<RouteResponse?> getOptimizedRoute({
    required LatLng origin,
    required List<LatLng> destinations,
    TravelMode mode = TravelMode.driving,
    bool optimizeWaypoints = true,
    double simplificationTolerance = 0.001,
  }) async {
    final completer = Completer<RouteResponse?>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final response = await _fetchOptimizedRoute(
          origin: origin,
          destinations: destinations,
          mode: mode,
          optimizeWaypoints: optimizeWaypoints,
        );

        if (response != null) {
          final simplified = _simplifyPolyline(
            response.polylinePoints,
            tolerance: simplificationTolerance,
          );
          completer.complete(response.copyWith(polylinePoints: simplified));
        } else {
          completer.complete(null);
        }
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Future<RouteResponse?> getOptimizedRouteFromAddresses({
    required String startAddress,
    required List<String> destinationAddresses,
    TravelMode mode = TravelMode.driving,
    double simplificationTolerance = 0.001,
  }) async {
    try {
      // تحويل العناوين إلى إحداثيات
      final startPoint = await _geocodeAddress(startAddress);
      if (startPoint == null) return null;

      final destPoints = await Future.wait(
        destinationAddresses.map((a) => _geocodeAddress(a)),
      ).then((points) => points.whereType<LatLng>().toList());

      if (destPoints.isEmpty) return null;

      // حساب المسار الأمثل
      return await getOptimizedRoute(
        origin: startPoint,
        destinations: destPoints,
        mode: mode,
        simplificationTolerance: simplificationTolerance,
      );
    } catch (e) {
      throw Exception('Failed to optimize route from addresses: $e');
    }
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

  Future<RouteResponse?> _fetchOptimizedRoute({
    required LatLng origin,
    required List<LatLng> destinations,
    required TravelMode mode,
    required bool optimizeWaypoints,
  }) async {
    if (destinations.length > 23) {
      throw Exception('Maximum 23 waypoints allowed by Google Directions API');
    }

    final cacheKey = _generateCacheKey(origin, destinations, mode);
    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey];
    }

    final waypoints = destinations
        .map((p) => '${p.latitude},${p.longitude}')
        .join('|');
    final url = Uri.parse(
      '$_directionsApiUrl?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${origin.latitude},${origin.longitude}&' // Round trip
      'waypoints=${optimizeWaypoints ? 'optimize:true|' : ''}$waypoints&'
      'mode=${mode.name}&'
      'key=$apiKey',
    );

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isEmpty) return null;

      final route = _parseRouteResponse(data);
      _routeCache[cacheKey] = route;
      return route;
    }
    return null;
  }

  RouteResponse _parseRouteResponse(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final legs = route['legs'] as List;
    final polyline = route['overview_polyline']['points'];

    return RouteResponse(
      polylinePoints: _decodePolyline(polyline),
      waypointOrder: List<int>.from(route['waypoint_order'] ?? []),
      legs:
          legs
              .map(
                (leg) => RouteLeg(
                  startLocation: LatLng(
                    leg['start_location']['lat'],
                    leg['start_location']['lng'],
                  ),
                  endLocation: LatLng(
                    leg['end_location']['lat'],
                    leg['end_location']['lng'],
                  ),
                  distance: leg['distance']['value'],
                  duration: leg['duration']['value'],
                ),
              )
              .toList(),
    );
  }

  List<LatLng> _simplifyPolyline(
    List<LatLng> points, {
    double tolerance = 0.001,
    bool highestQuality = false,
  }) {
    if (points.length <= 2) return points;

    final sqTolerance = tolerance * tolerance;
    List<LatLng> simplified =
        highestQuality
            ? List.from(points)
            : _simplifyRadialDistance(points, sqTolerance);
    simplified = _simplifyDouglasPeucker(simplified, sqTolerance);

    return simplified;
  }

  List<LatLng> _simplifyRadialDistance(
    List<LatLng> points,
    double sqTolerance,
  ) {
    var prevPoint = points[0];
    final newPoints = [prevPoint];

    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      if (_getSqDist(point, prevPoint) > sqTolerance) {
        newPoints.add(point);
        prevPoint = point;
      }
    }

    if (prevPoint != points.last) newPoints.add(points.last);
    return newPoints;
  }

  List<LatLng> _simplifyDouglasPeucker(
    List<LatLng> points,
    double sqTolerance,
  ) {
    final first = 0;
    final last = points.length - 1;
    final simplified = [points[first]];

    _simplifyDPStep(points, first, last, sqTolerance, simplified);
    simplified.add(points[last]);

    return simplified;
  }

  void _simplifyDPStep(
    List<LatLng> points,
    int first,
    int last,
    double sqTolerance,
    List<LatLng> simplified,
  ) {
    var maxSqDist = 0.0;
    var index = 0;

    for (var i = first + 1; i < last; i++) {
      final sqDist = _getSqSegDist(points[i], points[first], points[last]);
      if (sqDist > maxSqDist) {
        index = i;
        maxSqDist = sqDist;
      }
    }

    if (maxSqDist > sqTolerance) {
      if (index - first > 1)
        _simplifyDPStep(points, first, index, sqTolerance, simplified);
      simplified.add(points[index]);
      if (last - index > 1)
        _simplifyDPStep(points, index, last, sqTolerance, simplified);
    }
  }

  double _getSqDist(LatLng p1, LatLng p2) {
    final dx = p1.longitude - p2.longitude;
    final dy = p1.latitude - p2.latitude;
    return dx * dx + dy * dy;
  }

  double _getSqSegDist(LatLng p, LatLng p1, LatLng p2) {
    var x = p1.latitude;
    var y = p1.longitude;
    var dx = p2.latitude - x;
    var dy = p2.longitude - y;

    if (dx != 0 || dy != 0) {
      final t =
          ((p.latitude - x) * dx + (p.longitude - y) * dy) /
          (dx * dx + dy * dy);
      if (t > 1) {
        x = p2.latitude;
        y = p2.longitude;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }

    dx = p.latitude - x;
    dy = p.longitude - y;

    return dx * dx + dy * dy;
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  String _generateCacheKey(
    LatLng origin,
    List<LatLng> destinations,
    TravelMode mode,
  ) {
    final destKeys = destinations
        .map((p) => '${p.latitude},${p.longitude}')
        .join('|');
    return '${origin.latitude},${origin.longitude}|$destKeys|${mode.name}';
  }

  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}

enum TravelMode { driving, walking, bicycling, transit }

class RouteResponse {
  final List<LatLng> polylinePoints;
  final List<int> waypointOrder;
  final List<RouteLeg> legs;

  RouteResponse({
    required this.polylinePoints,
    required this.waypointOrder,
    required this.legs,
  });

  RouteResponse copyWith({
    List<LatLng>? polylinePoints,
    List<int>? waypointOrder,
    List<RouteLeg>? legs,
  }) {
    return RouteResponse(
      polylinePoints: polylinePoints ?? this.polylinePoints,
      waypointOrder: waypointOrder ?? this.waypointOrder,
      legs: legs ?? this.legs,
    );
  }
}

class RouteLeg {
  final LatLng startLocation;
  final LatLng endLocation;
  final int distance; // meters
  final int duration; // seconds

  RouteLeg({
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.duration,
  });
}
