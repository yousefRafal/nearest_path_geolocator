import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart'
    show AddressFile;
import 'package:test_geolocator_android/features/home/data/data_source/database_service.dart';

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

class LoadAddressesForFile extends AddressEvent {
  final int fileId;

  LoadAddressesForFile(this.fileId);

  @override
  List<Object> get props => [fileId];
}

class AddAddress extends AddressEvent {
  final Address address;
  final int fileId;

  AddAddress(this.address, this.fileId);

  @override
  List<Object> get props => [address, fileId];
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

class UpdateAddressStatus extends AddressEvent {
  final String addressId;
  final String newStatus;

  UpdateAddressStatus({required this.addressId, required this.newStatus});
}

// States
abstract class AddressState extends Equatable {
  @override
  List<Object> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressFilesLoaded extends AddressState {
  final List<AddressFile> files;

  AddressFilesLoaded(this.files);

  @override
  List<Object> get props => [files];
}

class AddressFileLoaded extends AddressState {
  final AddressFile file;

  AddressFileLoaded(this.file);

  @override
  List<Object> get props => [file];
}

class AddressError extends AddressState {
  final String message;

  AddressError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final DatabaseHelper _databaseHelper;

  AddressBloc(this._databaseHelper) : super(AddressInitial()) {
    on<LoadAddressFiles>(_onLoadAddressFiles);
    on<CreateAddressFile>(_onCreateAddressFile);
    on<LoadAddressesForFile>(_onLoadAddressesForFile);
    on<AddAddress>(_onAddAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<DeleteAddressFile>(_onDeleteAddressFile);
    on<MarkAddressAsDone>(_onMarkAddressAsDone);
  }

  Future<void> _onLoadAddressFiles(
    LoadAddressFiles event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    final file = AddressFile(
      date: DateTime.now(),
      name: 'test',
      addresses: [],
      id: 1,
    );

    emit(AddressFileLoaded(file));
    try {
      // emit(AddressFilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onCreateAddressFile(
    CreateAddressFile event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _databaseHelper.createAddressFile(event.file);
      final files = await _databaseHelper.getAllAddressFiles();
      emit(AddressFilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onLoadAddressesForFile(
    LoadAddressesForFile event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final file = AddressFile(
        date: DateTime.now(),
        name: 'test',
        addresses: [],
        // id: 1,
      );
      if (file != null) {
        emit(AddressFileLoaded(file));
      } else {
        emit(AddressError('Address file not found'));
      }
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      final file = AddressFile(
        date: DateTime.now(),
        name: 'test',
        addresses: [],
        // id: 1,
      );
      if (file != null) {
        emit(AddressFileLoaded(file));
        // emit(AddressFileLoaded(file));
      }
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _databaseHelper.deleteAddress(event.id);
      final files = await _databaseHelper.getAllAddressFiles();
      emit(AddressFilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDeleteAddressFile(
    DeleteAddressFile event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _databaseHelper.deleteAddressFile(event.id);
      final files = await _databaseHelper.getAllAddressFiles();
      emit(AddressFilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onMarkAddressAsDone(
    MarkAddressAsDone event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _databaseHelper.markAddressAsDone(event.id);
      final files = await _databaseHelper.getAllAddressFiles();
      emit(AddressFilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
