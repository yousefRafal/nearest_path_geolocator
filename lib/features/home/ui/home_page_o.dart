import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_geolocator_android/features/home/logic/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:test_geolocator_android/features/home/ui/last_addressing_page.dart';
import 'package:test_geolocator_android/features/home/ui/map_widget.dart';
import 'package:test_geolocator_android/features/home/ui/qr_scan_page.dart';
import 'package:test_geolocator_android/features/home/ui/widgets/qr_button.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/utils/bouncing_button.dart';

class HomePage extends StatefulWidget {
  List<Widget> get widgets => [const MapWidget(), const LastAddressingPage()];
  static const String routeName = Routes.homePage;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      extendBody: true,
      body: BlocConsumer<BottomNavigationCubit, BottomNavigationState>(
        listener: (context, state) {},
        builder: (context, state) {
          return widget.widgets[state.index];
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 20, top: 10),
        child: BouncingButton(
          duration: Duration(milliseconds: 150),
          pressScale: 0.85,
          onPress: () async {
            // await context.read<QrScanCubit>().initQrScan();
            Navigator.pushNamed(context, QRSearchOrderPage.routeName);
            // ScaleTransitionScreen(const QRSearchOrderPage());
            // Navigator.of(context).pushNamed(ScaleTransitionScreen(
            //     routeName: QRSearchOrderPage.routeName,
            //     builder: (context) => const QRSearchOrderPage()));
          },
          child: DiamondSquare(
            color: Theme.of(context).colorScheme.secondary,
            size: 30.w,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
        child: BottomAppBar(
          color: Colors.transparent,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const CircularNotchedRectangle(),
          notchMargin: 0,

          // shadowColor: const Color(234),
          elevation: 0,
          // color: color: Theme.of(context).colorScheme.secondary,,
          child: BlocConsumer<BottomNavigationCubit, BottomNavigationState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: BouncingButton(
                            onPress: () {
                              context.read<BottomNavigationCubit>().changeIndex(
                                0,
                              );
                            },
                            child: Icon(
                              state.index == 0
                                  ? Icons.home
                                  : Icons.home_outlined,
                              size: 30.w,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: BouncingButton(
                            onPress: () {
                              context.read<BottomNavigationCubit>().changeIndex(
                                1,
                              );
                            },
                            child: Icon(
                              state.index == 1
                                  ? Icons.category
                                  : Icons.category_outlined,
                              size: 30.w,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
