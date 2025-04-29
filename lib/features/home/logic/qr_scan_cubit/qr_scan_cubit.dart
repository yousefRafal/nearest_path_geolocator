import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

part 'qr_scan_state.dart';

class QrScanCubit extends Cubit<QrScanState> {
  QrScanCubit() : super(QrScanState(controller: null, detectedBarcode: null));

  void initQrController(QRViewController controller) {
    emit(state.copyWith(controller: controller));
  }

  Future<void> initQrScan() async {
    emit(
      state.copyWith(qrKey: GlobalKey(debugLabel: 'qr_scan'), isPaused: true),
    );
  }

  Future<void> pauseResumeCamera() async {
    if (state.isPaused == true) {
      await state.controller?.resumeCamera();
    } else {
      await state.controller?.pauseCamera();
    }
    emit(
      state.copyWith(
        isPaused: ((state.isPaused ?? false) ? false : true),
        detectedBarcode: null,
      ),
    );
  }

  Future<void> barcodeDetected(Barcode barcode) async {
    await state.controller?.pauseCamera();
    emit(state.copyWith(detectedBarcode: barcode, isPaused: true));
  }

  Future<void> toggleFlashLight() async {
    await state.controller?.toggleFlash();
    emit(state.copyWith(isFlashOn: (state.isFlashOn ?? false) ? false : true));
  }
}
