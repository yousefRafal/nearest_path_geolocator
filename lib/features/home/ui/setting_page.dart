import 'package:flutter/foundation.dart';
import 'package:geolocator_android/geolocator_android.dart';
// import 'package:geolocator/geolocator.dart';

LocationSettings getLocationSettings() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Example app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ),
      );

    default:
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              'Example app will continue to receive your location even when you aren\'t using it',
          notificationTitle: 'Running in Background',
          enableWakeLock: true,
        ),
      );
  }
}
