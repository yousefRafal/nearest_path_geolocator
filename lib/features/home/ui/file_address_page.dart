import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:test_geolocator_android/core/routes/routes.dart' show Routes;
import 'package:test_geolocator_android/features/home/data/address.dart';
import 'package:test_geolocator_android/features/home/data/address_file.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';

class FilesAddressPage extends StatefulWidget {
  static const String routeName = Routes.fileAddressScreen;
  const FilesAddressPage({super.key});

  @override
  State<FilesAddressPage> createState() => _FilesAddressPageState();
}

class _FilesAddressPageState extends State<FilesAddressPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddressFiles());
  }

  Future<void> _createNewAddressFile() async {
    final now = DateTime.now();
    final formattedDate = DateFormat.yMMMMd('ar').format(now);
    final file = AddressFile(date: now, name: formattedDate);
    context.read<AddressBloc>().add(CreateAddressFile(file));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
        child: Column(
          children: [
            BlocConsumer<AddressBloc, AddressState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is AddressLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FilesLoaded) {
                  return ListView.separated(
                    separatorBuilder:
                        (context, index) => SizedBox(height: 10.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.w,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.files.length,
                    itemBuilder: (context, index) {
                      final file = state.files[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRect(
                            clipBehavior: Clip.antiAlias,

                            child: Material(
                              // Added Material widget for better ink splash effects
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),

                              child: ExpansionTile(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                expandedAlignment: Alignment.centerLeft,
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                maintainState:
                                    true, // Preserves state when collapsed
                                onExpansionChanged: (expanded) {
                                  // Optional: Add animation callback if needed
                                },
                                expansionAnimationStyle: AnimationStyle(
                                  curve: Curves.easeInOut,
                                  reverseCurve: Curves.easeInOut,
                                  reverseDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                ),

                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5),

                                // iconColor: Theme.of(context).colorScheme.primary,
                                collapsedShape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                textColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withOpacity(0.9),
                                childrenPadding: EdgeInsets.all(10),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${file.addresses.length} عنوان',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                children: [
                                  ...file.addresses
                                      .take(3)
                                      .map(
                                        (address) => SizedBox(
                                          // height: 300.h,
                                          child: ListTile(
                                            title: Text(
                                              address.region,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            subtitle: Text(
                                              address.fullAddress,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleSmall?.copyWith(
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            trailing: Wrap(
                                              children: [
                                                if (!address.isDone)
                                                  IconButton(
                                                    style: IconButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .background,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              9,
                                                            ),
                                                      ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons
                                                          .done_outline_rounded,
                                                    ),
                                                    onPressed: () {
                                                      context
                                                          .read<AddressBloc>()
                                                          .add(
                                                            MarkAddressAsDone(
                                                              int.parse(
                                                                address.id,
                                                              ),
                                                            ),
                                                          );
                                                    },
                                                  ),
                                                IconButton(
                                                  style: IconButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    backgroundColor:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                    foregroundColor: Theme.of(
                                                          context,
                                                        ).colorScheme.error
                                                        .withOpacity(0.7),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                    ),
                                                  ),
                                                  // splashRadius: 10,
                                                  icon: Icon(
                                                    Icons
                                                        .delete_forever_outlined,
                                                  ),
                                                  onPressed: () {
                                                    context
                                                        .read<AddressBloc>()
                                                        .add(
                                                          DeleteAddress(
                                                            int.parse(
                                                              address.id,
                                                            ),
                                                          ),
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
                                    child: Row(
                                      // spacing: 40.w,
                                      // crossAxisAlignment:
                                      //     WrapCrossAlignment.center,
                                      // // clipBehavior: Clip.antiAlias
                                      // runAlignment: WrapAlignment.spaceAround,
                                      // direction: Axis.horizontal,
                                      // // verticalDirection: VerticalDirection.down,
                                      // // crossAxisAlignment:
                                      // //     WrapCrossAlignment.center,
                                      // // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      // // verticalDirection: VerticalDirection.down,
                                      // alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            try {
                                              Map<String, dynamic> addressJson =
                                                  json.decode('''
                                                      {
                                                      "order_id": "343",
                                                        "building_number": "7352",
                                                        "street": "شارع 50",
                                                        "district": "حي العزيزية",
                                                        "postal_code": "4234",
                                                        "city": "الرياض",
                                                        "is_done": 0,
                                                        "region": "منطقة الرياض",
                                                        "country": "المملكة العربية السعودية",
                                                        "full_address": "7352 شارع 50 حي العزيزية, الرياض 125335 المملكة العربية السعودية",

                                                        "lat": 25.7236,
                                                        "lng": 48.6853,
                                                      "status": "pending",
                                                      "scan_timestamp":3243423,
                                                      "id": "100"
                                                    }
                                              ''');

                                              Address address = Address.fromMap(
                                                addressJson,
                                              );
                                              context.read<AddressBloc>().add(
                                                AddAddress(
                                                  address,
                                                  fileId: file.id!,
                                                ),
                                              );
                                              // Navigator.pushReplacementNamed(
                                              //   context,
                                              //   Routes.homeScreen,
                                              //   // arguments: file.id,
                                              // );
                                            } catch (e) {}
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.2),
                                            foregroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                            // elevation: 0,
                                            // shadowColor: Colors.transparent,
                                          ),
                                          child: Text('إضافة عنوان'),
                                        ),
                                        if (file.addresses.isNotEmpty) ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.w,
                                                vertical: 10.h,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                side: BorderSide(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.surface,
                                                  width: 3,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.background,
                                              foregroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                            ),
                                            onPressed: () {
                                              // context.read<AddressBloc>().add(
                                              //   ShowFiledAddressing(file.id!),
                                              // );
                                              Navigator.pushNamed(
                                                context,
                                                Routes.mapScreen,
                                                arguments: file.id,
                                              );
                                            },
                                            child: Text(
                                              'عرض في الخريطة',
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (file.addresses.length > 3) ...[
                                    Center(
                                      child: TextButton(
                                        onPressed: () {},

                                        child: Text(
                                          'عرض الكل (${file.addresses.length - 3}+)',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.background,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is AddressError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                } else if (state is AddressFileLoaded) {
                  return const Center(child: Text('AddressFileLoaded'));
                }
                return const Center(child: Text('No address files found'));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAddressFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
