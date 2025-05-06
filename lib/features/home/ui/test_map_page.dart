import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
// import 'package:http/http.dart' as http;

class TestMap extends StatefulWidget {
  const TestMap({super.key});

  @override
  _TestMapState createState() => _TestMapState();
}

class _TestMapState extends State<TestMap> {
  late GoogleMapController mapController;
  // final http.Client _client = http.Client();

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final Set<Polygon> polygons = {};
  LatLng? userLocation;
  final List<LatLng> destinations = [
    LatLng(37.7749, -122.4194), // San Francisco
    LatLng(37.8051, -122.4300), // Point 2
    LatLng(37.8070, -122.4093), // Point 3
    LatLng(37.7950, -122.4020), // Point 4
    LatLng(37.7850, -122.4120), // Point 5
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Optimized using Future.delayed to prevent frame drops
  Future<void> _getUserLocation() async {
    try {
      print('===============');
      // final position = await Geolocator.getCurrentPosition();
      setState(() {
        userLocation = LatLng(37.7749, -122.4194);
        _addUserMarker();
        optimizeAndDrawRoute();
      });
    } catch (e) {
      setState(() {
        userLocation = const LatLng(37.7749, -122.4194); // Default fallback
        _addUserMarker();
        optimizeAndDrawRoute();
      });
    }
  }

  void _addUserMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId('userLocation'),
        position: userLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  // Nearest Neighbor Algorithm for route optimization
  List<LatLng> _optimizeRoute(List<LatLng> points) {
    if (points.isEmpty) return [];

    final optimizedRoute = <LatLng>[];
    final unvisited = List<LatLng>.from(points);

    // Start with user location or first point
    LatLng current = userLocation ?? unvisited.removeAt(0);
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

  // Haversine formula for distance calculation
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

  void optimizeAndDrawRoute() {
    if (userLocation == null) return;

    // Clear previous drawings
    polylines.clear();
    polygons.clear();
    markers.removeWhere((m) => m.markerId.value != 'userLocation');

    // Optimize route
    final optimizedRoute = _optimizeRoute(destinations);

    // Add destination markers
    for (var i = 0; i < optimizedRoute.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('dest_$i'),
          position: optimizedRoute[i],
          infoWindow: InfoWindow(title: 'Destination ${i + 1}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Draw optimized route
    polylines.add(
      Polyline(
        polylineId: const PolylineId('optimized_route'),
        points: optimizedRoute,
        color: Colors.blue,
        width: 4,
        geodesic: true,
      ),
    );

    // Draw area polygon (convex hull)
    final areaPoints = _computeConvexHull([userLocation!, ...optimizedRoute]);
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
    _zoomToRoute(optimizedRoute);
  }

  // Convex Hull algorithm (Graham Scan)

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

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.latitude - o.latitude) * (b.longitude - o.longitude) -
        (a.longitude - o.longitude) * (b.latitude - o.latitude);
  }

  Future<void> _zoomToRoute(List<LatLng> route) async {
    if (route.isEmpty) return;

    final bounds = _boundsFromLatLngList(route);
    await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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

  // Future<LatLng?> _geocodeAddress(String address) async {
  //   final cacheKey = 'geocode_${address.hashCode}';
  //   if (_routeCache.containsKey(cacheKey)) {
  //     return _routeCache[cacheKey]!.legs.first.startLocation;
  //   }

  //   try {
  //     final response = await _client.get(
  //       Uri.parse(
  //         '$https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=',
  //       ),
  //     );

  //     final data = json.decode(response.body);
  //     if (data['results'].isNotEmpty) {
  //       final location = data['results'][0]['geometry']['location'];
  //       final latLng = LatLng(location['lat'], location['lng']);

  //       // تخزين في الكاش للإستخدام اللاحق
  //       _routeCache[cacheKey] = RouteResponse(
  //         polylinePoints: [],
  //         waypointOrder: [],
  //         legs: [
  //           RouteLeg(
  //             startLocation: latLng,
  //             endLocation: latLng,
  //             distance: 0,
  //             duration: 0,
  //           ),
  //         ],
  //       );

  //       return latLng;
  //     }
  //   } catch (e) {
  //     print('Geocoding error for address $address: $e');
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimized Route Planner')),
      body: GoogleMap(
        onMapCreated: (controller) async {
          print('--------------print is full ');
          mapController = controller;
          await _getUserLocation();
          if (userLocation != null) {
            optimizeAndDrawRoute();
          }
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 12,
        ),
        markers: markers,
        polylines: polylines,
        polygons: polygons,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: optimizeAndDrawRoute,
      ),
    );
  }
}
