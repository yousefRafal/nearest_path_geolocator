import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:test_geolocator_android/core/routes/routes.dart' show Routes;
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';
import 'package:test_geolocator_android/features/home/ui/map_screen.dart';
import 'package:test_geolocator_android/features/home/ui/qr_scan_page.dart'
    show QRSearchOrderPage;
import 'package:test_geolocator_android/features/home/ui/widgets/scanner_page.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = Routes.homeScreen;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddressFiles());
  }

  Future<void> _createNewAddressFile() async {
    final now = DateTime.now();
    final file = AddressFile(
      date: now,
      name: DateFormat('MMMM d, y').format(now),
    );
    context.read<AddressBloc>().add(CreateAddressFile(file));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewAddressFile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AddressFilesLoaded) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];
                  return SizedBox(
                    // height: 300.h + 150.h,
                    child: Container(
                      // title: Text(file.name),
                      // subtitle: Text('${file.addresses.length} addresses'),
                      child: Wrap(
                        children: [
                          ...file.addresses.map(
                            (address) => SizedBox(
                              height: 300.h,
                              child: ListTile(
                                title: Text(address.orderId),
                                subtitle: Text(
                                  address.addressDetails.buildingNumber,
                                ),
                                trailing: Wrap(
                                  // mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (!address.isDone)
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () {
                                          context.read<AddressBloc>().add(
                                            MarkAddressAsDone(
                                              int.parse(address.id),
                                            ),
                                          );
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        context.read<AddressBloc>().add(
                                          DeleteAddress(int.parse(address.id)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.blue,
                                    ),
                                  ),
                                  onPressed: () async {
                                    // await _createNewAddressFile();
                                    Map<String, dynamic> addressJson = json
                                        .decode('''
{
  "order_id": "RUMC7351",
  "address_details": {
    "building_number": "7351",
    "street": "شارع القنا",
    "district": "حي المونسية",
    "postal_code": "13246",
    "city": "الرياض",
    "region": "منطقة الرياض",
    "country": "المملكة العربية السعودية",
    "full_address": "7351 شارع القنا، حي المونسية، الرياض 13246، المملكة العربية السعودية"
  },
  "coordinates": {
    "lat": 24.7136,
    "lng": 46.6753
  },
  "status": "pending",
  "scan_timestamp": "2023-11-20T14:30:00Z"
}
''');

                                    Address address = Address.fromJson(
                                      addressJson,
                                    );
                                    context.read<AddressBloc>().add(
                                      AddAddress(address, 1),
                                    );

                                    // Navigator.pushNamed(
                                    //   context,
                                    //   QRSearchOrderPage.routeName,
                                    // );
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   ScannerScreen.routeName,
                                    //   arguments: file.id!,
                                    // );
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder:
                                    //         (context) =>
                                    //             ScannerScreen(fileId: file.id!),
                                    //   ),
                                    // );
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text('Add Address'),
                                ),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.red,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.mapScreen,
                                      arguments: file.id,
                                    );
                                  },
                                  icon: const Icon(Icons.map),
                                  label: const Text('View Map'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is AddressError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No address files found'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAddressFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
