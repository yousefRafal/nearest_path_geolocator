import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:provider/provider.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';
import 'package:test_geolocator_android/core/utils/scale_transition_screen.dart';
import 'package:test_geolocator_android/features/home/data/data_source/database_service.dart';
import 'package:test_geolocator_android/features/home/logic/address_bloc.dart';
import 'package:test_geolocator_android/features/home/logic/qr_scan_cubit/qr_scan_cubit.dart';
import 'package:test_geolocator_android/features/home/ui/home_page_o.dart';
import 'package:test_geolocator_android/features/home/ui/map_screen.dart';
import 'package:test_geolocator_android/features/home/ui/widgets/home_page.dart';
import 'package:test_geolocator_android/features/home/ui/widgets/scanner_page.dart';

import '../../features/home/logic/bottom_navigation/bottom_navigation_cubit.dart';
import '../../features/home/ui/qr_scan_page.dart';

class AppRouter {
  Route genratedRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.routeName:
        return MaterialPageRoute(
          builder:
              (context) => Provider<BottomNavigationCubit>(
                create: (context) => BottomNavigationCubit(),
                child: const HomePage(),
              ),
        );
      // case LoginPage.routeName:
      //   return MaterialPageRoute(builder: (context) => const LoginPage());
      case Routes.barcodeScanner:
        return CustomPageRoute(
          child: Provider<QrScanCubit>(
            create: (_) => QrScanCubit()..initQrScan(),
            child: const QRSearchOrderPage(),
          ),
          routeType: RouteType.slideAndScale,
          slideBeginOffset: const Offset(0.0, 1.0), // انزلاق من الأسفل
          // builder: (context) => Provider<QrScanCubit>(
          //   create: (_) => QrScanCubit()..initQrScan(),
          //   child: const QRSearchOrderPage(),
          // ),
        );

      case Routes.homeScreen:
        return CustomPageRoute(
          child: BlocProvider(
            create:
                (context) =>
                    AddressBloc(DatabaseHelper())..add(LoadAddressFiles()),
            child: const HomeScreen(),
          ),
          routeType: RouteType.slideAndScale,
          slideBeginOffset: const Offset(0.0, 1.0), // انزلاق من الأسفل
          // builder: (context) => Provider<QrScanCubit>(
          //   create: (_) => QrScanCubit()..initQrScan(),
          //   child: const QRSearchOrderPage(),
          // ),
        );

      case Routes.scannerScreen:
        return CustomPageRoute(
          child: BlocProvider(
            create:
                (context) =>
                    AddressBloc(DatabaseHelper())..add(LoadAddressFiles()),
            child: ScannerScreen(fileId: settings.arguments as int),
          ),
          routeType: RouteType.slideAndScale,
          slideBeginOffset: const Offset(0.0, 1.0), // انزلاق من الأسفل
          // builder: (context) => Provider<QrScanCubit>(
          //   create: (_) => QrScanCubit()..initQrScan(),
          //   child: const QRSearchOrderPage(),
          // ),
        );

      case Routes.mapScreen:
        return CustomPageRoute(
          child: BlocProvider(
            create:
                (context) =>
                    AddressBloc(DatabaseHelper())..add(LoadAddressFiles()),
            child: MapScreen(fileId: settings.arguments as int),
          ),
          routeType: RouteType.slideAndScale,
          slideBeginOffset: const Offset(0.0, 1.0), // انزلاق من الأسفل
          // builder: (context) => Provider<QrScanCubit>(
          //   create: (_) => QrScanCubit()..initQrScan(),
          //   child: const QRSearchOrderPage(),
          // ),
        );
      default:
        return _errorRoute();
    }
  }

  Route _errorRoute() {
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}
