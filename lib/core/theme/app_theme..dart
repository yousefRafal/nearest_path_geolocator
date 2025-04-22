import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_geolocator_android/core/theme/app_text.dart';

class AppTheme {
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xFF4F46E5),
    onPrimary: Colors.white,
    secondary: Color(0xFF241E30),
    onSecondary: Color(0xFFE6EBEB),
    error: Colors.redAccent,
    inversePrimary: Color.fromARGB(255, 244, 247, 252),
    onSecondaryContainer: Color(0xFFE6EBEB),
    onTertiary: Color(0xFFE6EBEB),
    onTertiaryContainer: Color(0xFFE6EBEB),
    outline: Color(0xFFE6EBEB),
    outlineVariant: Color(0xFFE6EBEB),
    scrim: Color(0xFFE6EBEB),
    shadow: Color(0xFFE6EBEB),
    surfaceTint: Color(0xFFE6EBEB),
    tertiary: Color(0xFFE6EBEB),
    onSurfaceVariant: Color(0xFFE6EBEB),
    onError: Colors.white,
    background: Color(0xFF241E30),
    onBackground: Colors.white,
    surface: Color(0xFF241E30),
    onSurface: Colors.white,
    brightness: Brightness.dark,
  );

  static ThemeData appTeme = themeData(colorScheme, _lightFocusColor);
  static ThemeData themeData(
    ColorScheme colorScheme,
    Color focusColor,
  ) => ThemeData(
    colorScheme: colorScheme,
    primaryColor: colorScheme.inversePrimary,
    canvasColor: colorScheme.surface,
    scaffoldBackgroundColor: colorScheme.surface,
    highlightColor: Colors.transparent,
    focusColor: focusColor,
    cardColor: colorScheme.surface,
    dialogBackgroundColor: colorScheme.surface,
    indicatorColor: colorScheme.secondary,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    disabledColor: colorScheme.onSurface.withOpacity(0.4),
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
    buttonTheme: ButtonThemeData(
      buttonColor: colorScheme.secondary,
      textTheme: ButtonTextTheme.primary,
      disabledColor: colorScheme.onSecondary.withOpacity(0.4),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    ),
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
      color: colorScheme.onPrimary,
      size: 24.sp,
      opacity: 0.8,
      weight: const Icon(Icons.add).weight,
    ),
    //button style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0.r),
        ),
        minimumSize: Size(double.infinity, 38.0.h),
        shadowColor: colorScheme.shadow,
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.4),
        disabledForegroundColor: Colors.grey,
        padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
        textStyle: AppTextStyles.bodyText.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    ),
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
        backgroundColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.pressed))
            return colorScheme.primary.withOpacity(0.5);
          return colorScheme.surface; // Default Color
        }),
        overlayColor: MaterialStateProperty.all(
          colorScheme.primary.withOpacity(0.1),
        ), // Ripple color
        animationDuration: Duration(milliseconds: 200),
      ),
    ),

    appBarTheme: AppBarTheme(
      actionsIconTheme: IconThemeData(color: colorScheme.onPrimary),
      iconTheme: IconThemeData(
        color: colorScheme.onPrimary,
        size: 24.sp,
        opacity: 0.8.sp,
        weight: const Icon(Icons.add).weight,
      ),
      shadowColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      color: colorScheme.secondary,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
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
