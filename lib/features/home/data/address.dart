// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

class Address {
  final String id;
  final String orderId;
  // final AddressDetails addressDetails;
  final String status;
  final DateTime scanTimestamp;
  final bool isDone;
  final String buildingNumber;
  final String street;
  final String district;
  final String postalCode;
  final String city;
  final String region;
  final String country;
  final String fullAddress;
  final double lat;
  final int? fileId;
  final double lng;

  Address({
    this.fileId,
    required this.id,
    required this.orderId,
    required this.status,
    required this.scanTimestamp,
    required this.isDone,
    required this.buildingNumber,
    required this.street,
    required this.district,
    required this.postalCode,
    required this.city,
    required this.region,
    required this.country,
    required this.fullAddress,
    required this.lat,
    required this.lng,
  });

  Address copyWith({
    String? id,
    String? orderId,
    Coordinates? coordinates,
    String? status,
    DateTime? scanTimestamp,
    bool? isDone,
    String? buildingNumber,
    String? street,
    String? district,
    String? postalCode,
    String? city,
    String? region,
    String? country,
    String? fullAddress,
    double? lat,
    double? lng,
    int? fileId,
  }) {
    return Address(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      scanTimestamp: scanTimestamp ?? this.scanTimestamp,
      isDone: isDone ?? this.isDone,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      street: street ?? this.street,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      region: region ?? this.region,
      country: country ?? this.country,
      fullAddress: fullAddress ?? this.fullAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'file_id': fileId,
      'order_id': orderId,
      'is_done': isDone ? 1 : 0, // العمود الصحيح
      'status': status, // العمود الصحيح
      'scan_timestamp': scanTimestamp.millisecondsSinceEpoch,
      'building_number': buildingNumber,
      'street': street,
      'district': district,
      'postal_code': postalCode,
      'city': city,
      'region': region,
      'country': country,
      'full_address': fullAddress,
      'lat': lat,
      'lng': lng,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    // التحقق من القيم المطلوبة
    assert(map['id'] != null, 'Address ID is required');
    assert(
      map['lat'] != null && map['lng'] != null,
      'Coordinates are required',
    );

    // التحقق من صحة الحالة
    final status = map['status']?.toString().toLowerCase() ?? 'pending';
    assert(
      ['pending', 'delivered', 'cancelled'].contains(status),
      'Invalid status value',
    );

    return Address(
      id: map['id'] as String,
      fileId: map['file_id'] as int?, // يسمح بقيمة null
      orderId: map['order_id']?.toString() ?? '',
      status: status,
      scanTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['scan_timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isDone: map['is_done'] == 1,
      buildingNumber: map['building_number']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      postalCode: map['postal_code']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      region: map['region']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      fullAddress:
          map['full_address']?.toString() ?? '', // تم تصحيح الخطأ الإملائي
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) =>
      Address.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Address(id: $id, orderId: $orderId, status: $status, scanTimestamp: $scanTimestamp, isDone: $isDone, buildingNumber: $buildingNumber, street: $street, district: $district, postalCode: $postalCode, city: $city, region: $region, country: $country, fullAddress: $fullAddress, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(covariant Address other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.orderId == orderId &&
        other.status == status &&
        other.scanTimestamp == scanTimestamp &&
        other.isDone == isDone &&
        other.buildingNumber == buildingNumber &&
        other.street == street &&
        other.district == district &&
        other.postalCode == postalCode &&
        other.city == city &&
        other.region == region &&
        other.country == country &&
        other.fullAddress == fullAddress &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        status.hashCode ^
        scanTimestamp.hashCode ^
        isDone.hashCode ^
        buildingNumber.hashCode ^
        street.hashCode ^
        district.hashCode ^
        postalCode.hashCode ^
        city.hashCode ^
        region.hashCode ^
        country.hashCode ^
        fullAddress.hashCode ^
        lat.hashCode ^
        lng.hashCode;
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
    log("json.toString()");

    log(json.toString());
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
