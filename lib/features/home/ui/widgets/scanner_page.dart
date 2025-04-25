import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:test_geolocator_android/core/routes/routes.dart' show Routes;
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  static const String routeName = '/scannerScreen';
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
          address = Address.fromJson(jsonData);
        } catch (e) {
          throw Exception('Invalid JSON format in QR code');
        }
      }
      // باقي أنواع الباركود (خرائط جوجل، geo، إلخ...)
      // الحالة 4: التنسيق النصي (الافتراضي)
      else {
        // address = await _parseOtherFormats(code);
      }

      if (address != null) {
        if (mounted) {
          context.read<AddressBloc>().add(AddAddress(address, widget.fileId));
          Navigator.pushNamed(
            context,
            Routes.mapScreen,
            arguments: widget.fileId,
          );
        }
      } else {
        throw Exception('Unsupported QR code format');
      }
    } catch (e) {
      log('Error processing QR code: ${e.toString()}');
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
                      title: const Text('Supported QR Formats'),
                      content: const Text(
                        '1. Order|Address (e.g. ORD123|123 Main St)\n'
                        '2. Google Maps URL (e.g. http://maps.google.com/...)\n'
                        '3. Geo URI (e.g. geo:51.41,5.44)\n'
                        '4. JSON format with order details',
                      ),
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
