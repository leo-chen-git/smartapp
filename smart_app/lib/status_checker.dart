import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:smart_app/preferences.dart';

final location = Location();

Future<bool> checkPermission() async {
  if (await _needLocationPermission()) {
    log('get location permission');
    await location.requestPermission();
  }

  if (await _needRequestFCMToken()) {
    await Preferences.instance.setFcmToken(await _requestFCMToken());
  }

  return true;
}

Future<bool> _needLocationPermission() async {
  final hasPermission = await location.hasPermission();

  return !(hasPermission == PermissionStatus.granted ||
      hasPermission == PermissionStatus.grantedLimited);
}

Future<bool> _needRequestFCMToken() async {
  final version = Preferences.instance.version;

  // very first time open app
  if (version == 0) {
    await Preferences.instance.setVersion(1);
    return true;
  }

  return Preferences.instance.fcmToken.isEmpty;
}

Future<String> _requestFCMToken() async {
  final permission = await FirebaseMessaging.instance.requestPermission();
  log('get notification permission: ${permission.authorizationStatus}');

  final token = await FirebaseMessaging.instance.getToken() ?? '';

  return token;
}
