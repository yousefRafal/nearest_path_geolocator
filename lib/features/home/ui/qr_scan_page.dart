import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/features/home/logic/qr_scan_cubit/qr_scan_cubit.dart';
import 'package:test_geolocator_android/features/home/ui/widgets/home_page.dart';

class QRSearchOrderPage extends StatefulWidget {
  const QRSearchOrderPage({super.key});
  static const String routeName = Routes.barcodeScanner;

  @override
  State<QRSearchOrderPage> createState() => _QRSearchOrderPageState();
}

class _QRSearchOrderPageState extends State<QRSearchOrderPage> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        } else {}
        return Future.value(false);
      },
      child: Scaffold(
        body: BlocConsumer<QrScanCubit, QrScanState>(
          listener: (context, state) {
            Barcode? detectedBarcode = state.detectedBarcode;
            if (detectedBarcode != null) {
              String? barcode = detectedBarcode.code;
              if (barcode != null) {
                Clipboard.setData(ClipboardData(text: barcode));

                // context
                //     .read<GlobalSearchBloc>()
                //     .add(const SearchFromClipBoard());
                Navigator.of(context).pushReplacementNamed(HomePage.routeName);
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (state.qrKey != null)
                        _buildQrView(
                          qrKey:
                              state.qrKey ?? GlobalKey(debugLabel: 'qr_scan'),
                          context: context,
                        ),
                      Positioned(
                        bottom: 20,
                        right: 30,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                context.read<QrScanCubit>().toggleFlashLight();
                              },
                              icon:
                                  state.isFlashOn ?? false
                                      ? const Icon(
                                        Icons.flash_off,
                                        color: Colors.white,
                                        size: 36,
                                      )
                                      : const Icon(
                                        Icons.flash_on,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "البحث عن عنوان",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon:
                                  state.isPaused ?? false
                                      ? Icon(
                                        Icons.play_arrow,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      )
                                      : Icon(
                                        Icons.pause,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                              onPressed: () async {
                                context.read<QrScanCubit>().pauseResumeCamera();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQrView({
    required GlobalKey qrKey,
    required BuildContext context,
  }) {
    var scanArea = MediaQuery.of(context).size.width * 0.8;
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) async {
        controller.scannedDataStream.listen((scanData) {
          // context.read<QrScanBloc>().add(const PauseResumeCamera());
          context.read<QrScanCubit>().barcodeDetected(scanData);
        });
        context.read<QrScanCubit>().initQrController(controller);
      },
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void barcodeDetected(String? barcode) async {}

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('permissions');
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }
}
