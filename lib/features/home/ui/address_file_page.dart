import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart';

class AddressFilePage extends StatelessWidget {
  final AddressFile file;
  const AddressFilePage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ملف ${file.name}')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: SingleChildScrollView(
          child: Column(
            children:
                file.addresses
                    .map((address) => _addressFileWidget(address, context))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _addressFileWidget(Address address, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
        border:
            address.isDone == true
                ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                )
                : null,

        color:
            address.isDone == true
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : null,
      ),
      child: Column(
        children: [Text(address.region ?? ''), Text(address.fullAddress)],
      ),
    );
  }
}
