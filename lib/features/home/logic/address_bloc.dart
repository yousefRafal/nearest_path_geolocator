import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart'
    show AddressFile;
import 'package:test_geolocator_android/features/home/data/data_source/database_service.dart';
part 'address_state.dart';
part 'address_event.dart';

// Bloc
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final DatabaseHelper _databaseHelper;

  AddressBloc(this._databaseHelper) : super(AddressInitial()) {
    on<LoadAddressFiles>(_onLoadAddressFiles);
    on<CreateAddressFile>(_onCreateAddressFile);
    on<AddAddress>(_onAddAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<DeleteAddressFile>(_onDeleteAddressFile);
    on<MarkAddressAsDone>(_onMarkAddressAsDone);
    on<ShowFiledAddressing>(_showFiledAddressing);
  }

  Future<void> _onLoadAddressFiles(
    LoadAddressFiles event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    final files = await _databaseHelper.getAllAddressFiles();
    emit(FilesLoaded(files));

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
      print('event files is  ${event.file.toMap()}');
      await _databaseHelper.createAddressFile(event.file);
      final files = await _databaseHelper.getAllAddressFiles();
      emit(FilesLoaded(files));
    } catch (e) {
      print(' error when add file address  : $e');
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      log('event is $event');
      final address = event.address;
      await _databaseHelper.insertAddress(
        address.copyWith(fileId: event.fileId),
      );
      final files = await _databaseHelper.getAllAddressFiles();

      emit(FilesLoaded(files));
    } catch (e) {
      log('error is $e');
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
      emit(FilesLoaded(files));
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
      emit(FilesLoaded(files));
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
      emit(FilesLoaded(files));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _showFiledAddressing(
    ShowFiledAddressing event,
    Emitter<AddressState> emit,
  ) async {
    try {
      emit(AddressLoading());
      if (event.fileId == null) {
        final fileId = await _databaseHelper.getOrCreateTodayFile(
          date: DateTime.now(),
        );
        await _databaseHelper.getAddressesForFile(fileId).then((value) {
          emit(AddressFileLoaded(value, fileId: fileId));
        });
      } else {
        print('event ${event.fileId}');
        await _databaseHelper.getAddressesForFile(event.fileId!).then((value) {
          print(
            '========================  ${value.map((toElement) => toElement.toJson())}',
          );
          emit(AddressFileLoaded(value, fileId: event.fileId!));
        });
      }
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
