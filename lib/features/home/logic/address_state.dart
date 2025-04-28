part of 'address_bloc.dart';

// States
abstract class AddressState extends Equatable {
  @override
  List<Object> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class FilesLoaded extends AddressState {
  final List<AddressFile> files;

  FilesLoaded(this.files);

  @override
  List<Object> get props => [files];
}

class AddressFileLoaded extends AddressState {
  final List<Address> addresses;

  AddressFileLoaded(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;

  AddressError(this.message);

  @override
  List<Object> get props => [message];
}
