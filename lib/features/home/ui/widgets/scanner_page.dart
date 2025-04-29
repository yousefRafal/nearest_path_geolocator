import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:test_geolocator_android/core/routes/routes.dart' show Routes;
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  static const String routeName = Routes.scannerScreen;
  final int fileId;

  const ScannerScreen({super.key, required this.fileId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String code) async {
    if (isProcessing) return;
    isProcessing = true;

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
      }
      // باقي أنواع الباركود (خرائط جوجل، geo، إلخ...)
      // الحالة 4: التنسيق النصي (الافتراضي)
      else {
        // address = await _parseOtherFormats(code);
      }

      if (address != null) {
        if (mounted) {
          AlertDialog(
            title: const Text('نتيجة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل تريد عرض العنوان على الخريطة؟'),
                const SizedBox(height: 10),
                Text('العنوان : ${address.fullAddress}'),
                const SizedBox(height: 20),
                const Text('ام تريد اضافة المزيد من العناوين ؟'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.mapScreen),
                child: const Text('عرض'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AddressBloc>().add(
                    AddAddress(address!, fileId: widget.fileId),
                  );
                },
                child: const Text('اضافة العنوان'),
              ),
            ],
          );
        }
      } else {
        throw Exception('تنسسيق غير مدعوم');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      // عرض خيار الإدخال اليدوي عند الخطأ
      _showManualEntryOption(code);
    } finally {
      isProcessing = false;
    }
  }

  void _showManualEntryOption(String scannedCode) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code Not Recognized'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The scanned QR code format is not supported.'),
                const SizedBox(height: 10),
                Text('Scanned data: $scannedCode'),
                const SizedBox(height: 20),
                const Text('Would you like to enter the data manually?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _navigateToManualEntry(scannedCode);
                },
                child: const Text('Manual Entry'),
              ),
            ],
          ),
    );
  }

  void _navigateToManualEntry() {
    // الانتقال إلى شاشة الإدخال اليدوي
    // يمكنك تنفيذ هذه الشاشة بشكل منفصل
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Order QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('التنسيقات المدعومة'),
                      content: const Text('1. JSON format with order details'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) {
            if (scanData.code != null) {
              _processQRCode(scanData.code!);
            }
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToManualEntry,
        tooltip: 'Manual Entry',
        child: const Icon(Icons.keyboard),
      ),
    );
  }
}
