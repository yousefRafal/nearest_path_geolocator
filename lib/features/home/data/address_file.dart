import 'package:equatable/equatable.dart';
import 'address.dart';

class AddressFile extends Equatable {
  final int? id;
  final DateTime date;
  final String name;
  final List<Address> addresses;

  const AddressFile({
    this.id,
    required this.date,
    required this.name,
    this.addresses = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().toString(),
      'name': name.toString(),
    };
  }

  factory AddressFile.fromMap(Map<String, dynamic> map) {
    return AddressFile(
      id: map['id'],
      date: DateTime.parse(map['date']),
      name: map['name'],
      addresses: const [],
    );
  }

  AddressFile copyWith({
    int? id,
    DateTime? date,
    String? name,
    List<Address>? addresses,
  }) {
    return AddressFile(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  List<Object?> get props => [id, date, name, addresses];
}
