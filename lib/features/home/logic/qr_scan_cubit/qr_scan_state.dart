// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'qr_scan_cubit.dart';

class QrScanState {
  final Barcode? detectedBarcode;
  final QRViewController? controller;
  final bool? isFlashOn, isPaused;
  GlobalKey? qrKey;

  QrScanState({
    required this.detectedBarcode,
    required this.controller,
    this.isFlashOn = false,
    this.isPaused = false,
    this.qrKey,
  });

  QrScanState copyWith({
    Barcode? detectedBarcode,
    QRViewController? controller,
    bool? isFlashOn,
    bool? isPaused,
    GlobalKey? qrKey,
  }) {
    return QrScanState(
      isFlashOn: isFlashOn ?? this.isFlashOn,
      detectedBarcode: detectedBarcode ?? this.detectedBarcode,
      controller: controller ?? this.controller,
      isPaused: isPaused ?? this.isPaused,
      qrKey: qrKey ?? this.qrKey,
    );
  }
}
