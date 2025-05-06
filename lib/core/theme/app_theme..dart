import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_geolocator_android/core/theme/app_text.dart';

class AppTheme {
  static final Color _lightFocusColor = const Color.fromARGB(
    255,
    34,
    81,
    38,
  ).withOpacity(0.12);

  static ColorScheme colorScheme = const ColorScheme(
    primary: const Color(0xFF235D3A),

    onPrimary: Color.fromARGB(255, 252, 252, 252),
    secondary: Color(0xFF1D2E28),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    inversePrimary: Color.fromARGB(255, 54, 131, 255),
    onSecondaryContainer: Color(0xFF241E30),
    onTertiary: Colors.white,
    onTertiaryContainer: Color(0xFF241E30),
    outline: Color(0xFF241E30),
    outlineVariant: Color(0xFF241E30),
    scrim: Color(0xFF241E30),
    shadow: Color(0xFF241E30),
    surfaceTint: Color(0xFF241E30),
    tertiary: Colors.black12,
    onSurfaceVariant: Color(0xFF241E30),
    onError: Colors.white,
    background: Color.fromARGB(255, 245, 255, 244),
    onBackground: Color(0xFF241E30),
    surface: Color(0xFF73C088),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static ThemeData appTeme = themeData(colorScheme, _lightFocusColor);
  static ThemeData themeData(
    ColorScheme colorScheme,
    Color focusColor,
  ) => ThemeData(
    fontFamily: 'FormaDJRDisplay',
    colorScheme: colorScheme,
    // primaryColor: colorScheme.inversePrimary,
    // canvasColor: colorScheme.surface,
    // scaffoldBackgroundColor: colorScheme.surface,
    // highlightColor: Colors.transparent,
    // focusColor: focusColor,
    // cardColor: colorScheme.surface,
    // dialogBackgroundColor: colorScheme.surface,
    // indicatorColor: colorScheme.secondary,
    // hoverColor: Colors.transparent,
    // splashColor: Colors.transparent,
    // disabledColor: colorScheme.onSurface.withOpacity(0.4),
    //card
    cardTheme: CardTheme(
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.primary,

      elevation: 0.6,
      // margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    // buttonTheme: ButtonThemeData(
    //   buttonColor: colorScheme.onError,
    //   textTheme: ButtonTextTheme.primary,
    //   disabledColor: colorScheme.onSecondary.withOpacity(0.4),
    //   padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    // ),
    snackBarTheme: SnackBarThemeData(
      showCloseIcon: true,
      backgroundColor: colorScheme.onSecondary,
      behavior: SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      dismissDirection: DismissDirection.horizontal,
      insetPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      actionTextColor: colorScheme.onPrimary,
      contentTextStyle: AppTextStyles.bodyText.copyWith(
        color: colorScheme.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        overlayColor: colorScheme.surface,
        side: BorderSide(color: colorScheme.primary, width: 2),

        foregroundColor: colorScheme.onError,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),

        backgroundColor: colorScheme.surface,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      disabledElevation: 0.0,
      elevation: 0.0,

      focusElevation: 0.0,
      hoverElevation: 0.0,
      highlightElevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLargeText.copyWith(
        color: colorScheme.onPrimary,
      ),
      displayMedium: AppTextStyles.displayMediumText.copyWith(
        color: colorScheme.onPrimary,
      ),
      displaySmall: AppTextStyles.displaySmallText.copyWith(
        color: colorScheme.onPrimary,
      ),
      labelLarge: AppTextStyles.labelLargeText.copyWith(
        color: colorScheme.onPrimary,
      ),
      labelMedium: AppTextStyles.labelMediumText.copyWith(
        color: colorScheme.onPrimary,
      ),
      labelSmall: AppTextStyles.bodyText.copyWith(
        color: colorScheme.onPrimary,
        fontSize: 12.0.sp,
        letterSpacing: 1.5,
      ),
      bodyLarge: AppTextStyles.bodyLargeText.copyWith(
        color: colorScheme.onPrimary,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: AppTextStyles.bodyMediumText.copyWith(
        color: colorScheme.onPrimary,
        letterSpacing: 0.25,
      ),
      bodySmall: AppTextStyles.bodySmallText.copyWith(
        color: colorScheme.onPrimary,
        fontSize: 11.0.sp,
        letterSpacing: 0.4,
      ),
      headlineLarge: AppTextStyles.headerLarge.copyWith(
        color: colorScheme.onPrimary,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: AppTextStyles.headerMedium.copyWith(
        color: colorScheme.onPrimary,
        fontSize: 20.0.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: AppTextStyles.headerSmall.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      titleLarge: AppTextStyles.titleLargeText.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleMedium: AppTextStyles.titleMediumText.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      titleSmall: AppTextStyles.bodyText.copyWith(
        color: colorScheme.onPrimary,
        fontSize: 12.0.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
    //icon theme
    iconTheme: IconThemeData(
      color: colorScheme.primary,
      size: 24.sp,
      opacity: 0.8,

      weight: const Icon(Icons.add).weight,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: AppTextStyles.labelMediumText.copyWith(
        color: Colors.black.withOpacity(0.4),
        fontWeight: FontWeight.bold,
      ),
      hintStyle: AppTextStyles.labelMediumText.copyWith(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    ),

    //button style
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 2.0,
        minimumSize: Size(double.infinity, 50.0.h),
        shadowColor: colorScheme.primaryContainer,
        side: BorderSide(color: colorScheme.secondary, width: 1.5),
        disabledForegroundColor: Colors.grey,
        foregroundColor: colorScheme.primary,
        textStyle: AppTextStyles.bodyText.copyWith(
          color: colorScheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0.r),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            // ignore: deprecated_member_use
            return colorScheme.primary.withOpacity(0.5);
          }
          return colorScheme.surface; // Default Color
        }),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withOpacity(0.1),
        ), // Ripple color
        animationDuration: Duration(milliseconds: 200),
      ),
    ),

    appBarTheme: AppBarTheme(
      foregroundColor: colorScheme.onPrimary,
      // titleSpacing: 30,
      titleTextStyle: AppTextStyles.headerMedium.copyWith(
        color: colorScheme.onPrimary,
      ),
      actionsIconTheme: IconThemeData(color: colorScheme.background),

      shadowColor: Colors.transparent,
      elevation: 0.0,
      // backgroundColor: colorScheme.surface,
      // surfaceTintColor: Colors.red,
      centerTitle: true,

      actionsPadding: EdgeInsets.symmetric(horizontal: 20.w),
      color: colorScheme.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surface.withOpacity(0.10),
        statusBarIconBrightness:
            colorScheme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            colorScheme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
    ),
  );
}
