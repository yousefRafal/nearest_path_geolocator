import 'dart:convert';
import 'dart:developer';

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
        // leadingWidth: 50,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          constraints: BoxConstraints(
            minWidth: 30.w,
            minHeight: 30.h,
            maxHeight: 40.h,
            maxWidth: 40.w,
          ),
          autofocus: false,
          padding: EdgeInsets.zero,
          iconSize: 20.sp,
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          alignment: Alignment.center,

          style: IconButton.styleFrom(
            iconSize: 20.sp,
            alignment: Alignment.center,
            padding: EdgeInsets.zero,

            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            foregroundColor: Theme.of(context).colorScheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          // onPressed: ,
        ),
        title: const Text('ملفات العناوين'),
        actions: [
          IconButton(
            constraints: BoxConstraints(
              minWidth: 30.w,
              minHeight: 30.h,
              maxHeight: 40.h,
              maxWidth: 40.w,
            ),
            style: IconButton.styleFrom(
              alignment: Alignment.center,
              padding: EdgeInsets.zero,

              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.3),
              foregroundColor: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            icon: const Icon(Icons.add),
            onPressed: _createNewAddressFile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocConsumer<AddressBloc, AddressState>(
              listener: (context, state) {
                if (state is AddressError) {
                  //dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Column(
                          children: [
                            Text(
                              'خطأ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 20.h),
                            Icon(
                              size: 43.r,
                              Icons.cancel_outlined,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ],
                        ),
                        content: Text(state.message),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('اغلاق'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ).then((value) {
                    if (context.mounted) {
                      context.read<AddressBloc>().add(LoadAddressFiles());
                    }
                  });
                }
              },
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
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRect(
                            clipBehavior: Clip.antiAlias,

                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),

                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(
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
                                          child: ListTile(
                                            title: Text(
                                              address.region ?? '',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              address.fullAddress,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleSmall?.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: Wrap(
                                              children: [
                                                if (address.isDone != null &&
                                                    address.isDone == true)
                                                  IconButton(
                                                    style: IconButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor: Theme.of(
                                                            context,
                                                          )
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.5),
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
                                                    backgroundColor: Theme.of(
                                                          context,
                                                        ).colorScheme.secondary
                                                        .withOpacity(0.5),
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
                                                      "order_id": "4234",
                                                        "building_number": "7352",
                                                        "street": "شارع 50",
                                                        "district": "حي العزيزية",
                                                        "postal_code": "4234",
                                                        "city": "الرياض",
                                                        "is_done": 0,
                                                        "region": "منطقة الرياض",
                                                        "country": "المملكة العربية السعودية",
                                                        "full_address": "RUMC7351، 7351 القنا، 3255، المونسية، الرياض 13246، السعودية, الرياض, السعودية",
                                                        "lat": 25.7236,
                                                        "lng": 48.6853,
                                                      "status": "pending",
                                                      "scan_timestamp":3243423,
                                                      "id": "5433"
                                                    }
                                              ''');
                                              log(file.id.toString());
                                              Address address = Address.fromMap(
                                                addressJson,
                                              );
                                              context.read<AddressBloc>().add(
                                                AddAddress(
                                                  address,
                                                  fileId: file.id!,
                                                ),
                                              );
                                            } catch (e) {
                                              // print('object');
                                            }
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
                                              Navigator.pushNamed(
                                                context,
                                                Routes.tcpRoutes,
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _createNewAddressFile,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
//رقم 255، المونسية، الرياض 13246، السعودية
//رقم 255، المونسية، الرياض 13246، السعودية