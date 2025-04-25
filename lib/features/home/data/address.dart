class Address {
  final String id;
  final String orderId;
  final AddressDetails addressDetails;
  final Coordinates coordinates;
  final String status;
  final DateTime scanTimestamp;
  final bool isDone;

  Address({
    required this.orderId,
    required this.addressDetails,
    required this.coordinates,
    this.status = 'pending',
    required this.scanTimestamp,
    this.isDone = false,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Address.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException('Invalid JSON data');
    }

    return Address(
      orderId: json['order_id'] as String? ?? 'UNKNOWN',
      addressDetails: AddressDetails.fromJson(
        json['address_details'] as Map<String, dynamic>? ?? {},
      ),
      coordinates: Coordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status'] as String? ?? 'pending',
      scanTimestamp: DateTime.parse(
        json['scan_timestamp'] as String? ?? '2000-01-01T00:00:00Z',
      ),
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'address_details': addressDetails.toJson(),
      'coordinates': coordinates.toJson(),
      'status': status,
      'scan_timestamp': scanTimestamp.toIso8601String(),
      'id': id,
    };
  }
}

class AddressDetails {
  final String buildingNumber;
  final String street;
  final String district;
  final String postalCode;
  final String city;
  final String region;
  final String country;
  final String fullAddress;

  AddressDetails({
    required this.buildingNumber,
    required this.street,
    required this.district,
    required this.postalCode,
    required this.city,
    required this.region,
    required this.country,
    required this.fullAddress,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      buildingNumber: json['building_number'] as String? ?? '',
      street: json['street'] as String? ?? '',
      district: json['district'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      country: json['country'] as String? ?? '',
      fullAddress: json['full_address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building_number': buildingNumber,
      'street': street,
      'district': district,
      'postal_code': postalCode,
      'city': city,
      'region': region,
      'country': country,
      'full_address': fullAddress,
    };
  }
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}
