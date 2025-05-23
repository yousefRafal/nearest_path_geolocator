import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/data_source/database_service.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';
import 'package:test_geolocator_android/features/home/logic/qr_scan_cubit/qr_scan_cubit.dart';
import 'package:test_geolocator_android/features/home/ui/home_page_o.dart';

class QRSearchOrderPage extends StatefulWidget {
  const QRSearchOrderPage({super.key});
  static const String routeName = Routes.barcodeScanner;

  @override
  State<QRSearchOrderPage> createState() => _QRSearchOrderPageState();
}

class _QRSearchOrderPageState extends State<QRSearchOrderPage> {
  late int filedId;
  @override
  void initState() {
    super.initState();
  }

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
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.all(5.dg),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              onPressed: () async {
                                context.read<QrScanCubit>().toggleFlashLight();
                              },

                              icon:
                                  state.isFlashOn ?? false
                                      ? Icon(
                                        Icons.flash_off,
                                        color: Colors.white,
                                        size: 20.w,
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
        context.read<QrScanCubit>().initQrController(controller);
        controller.scannedDataStream.listen((scanData) {
          log('scannedDataStream');
          log(scanData.code.toString());
          if (context.mounted) {
            context.read<QrScanCubit>().pauseResumeCamera().then((v) {
              _processQRCode(scanData.code?.toString() ?? "", context);
              // Navigator.of(context).pop();
            });
          }
          // if (!context.mounted) {
          // context.read<QrScanCubit>().pauseResumeCamera();

          // }
        });
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

  Future<void> _processQRCode(String code, BuildContext context) async {
    try {
      log(code);
      Address? address;

      // الحالة 1: رابط خرائط جوجل

      // الحالة 2: تنسيق geo
      // الحالة 3: تنسيق JSON
      if (code.trim().startsWith('{') && code.trim().endsWith('}')) {
        try {
          final jsonData = json.decode(code) as Map<String, dynamic>;
          address = Address.fromMap(jsonData);
        } catch (e) {
          throw Exception('خطأ في قراءة الباركود يجب قراءة باركود صحيح');
        }
      } else {
        final fileId = await DatabaseHelper().getOrCreateTodayFile(
          date: DateTime.now(),
        );
        final fullAddress = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'lat': 0.0,
          'lng': 0.0,
          'building_number': '',
          'street': '',
          'district': '',
          'postal_code': '',
          'city': '',
          'region': '',
          'country': '',
          'status': 'pending',
          'scan_timestamp': 32434234234,
          'is_done': 0,
          'order_id': '',
          'file_id': fileId,
          'full_address': code,
        };
        address = Address.fromMap(fullAddress);
      }

      // if (mounted) {
      SnackBar snackBar = SnackBar(
        content: Text('تم إضافة العنوان بنجاح'),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // }

      context.read<AddressBloc>().add(AddAddress(address, fileId: filedId));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      // عرض خيار الإدخال اليدوي عند الخطأ
    } finally {}
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
