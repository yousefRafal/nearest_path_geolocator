part of 'address_bloc.dart';

// Events
abstract class AddressEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadAddressFiles extends AddressEvent {}

class CreateAddressFile extends AddressEvent {
  final AddressFile file;

  CreateAddressFile(this.file);

  @override
  List<Object> get props => [file];
}

class AddAddress extends AddressEvent {
  final Address address;
  final int? fileId;

  AddAddress(this.address, {this.fileId});

  @override
  List<Object> get props => [address];
}

class DeleteAddress extends AddressEvent {
  final int id;

  DeleteAddress(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteAddressFile extends AddressEvent {
  final int id;

  DeleteAddressFile(this.id);

  @override
  List<Object> get props => [id];
}

class MarkAddressAsDone extends AddressEvent {
  final int id;

  MarkAddressAsDone(this.id);

  @override
  List<Object> get props => [id];
}

class ShowFiledAddressing extends AddressEvent {
  final int fileId;
  ShowFiledAddressing(this.fileId);
  @override
  List<Object> get props => [fileId];
}

class UpdateAddressStatus extends AddressEvent {
  final String addressId;
  final String newStatus;

  UpdateAddressStatus({required this.addressId, required this.newStatus});
}
