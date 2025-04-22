import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_geolocator_android/core/routes/routes.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme..dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  runApp(MyApp(appRouter: AppRouter()));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  AppRouter appRouter;

  MyApp({super.key, required this.appRouter});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: false,
      builder: (context, child) {
        return MaterialApp(
          initialRoute: Routes.homePage,
          debugShowCheckedModeBanner: false,
          title: 'Route Optimizer',
          theme: AppTheme.appTeme,
          onGenerateRoute: appRouter.genratedRoute,
          // home: const HomePage(),
        );
      },
    );
  }
}
