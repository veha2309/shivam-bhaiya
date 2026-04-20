import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static String? deviceId;
  static String? firebaseToken;

  /// Fetches device ID based on the platform
  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        return deviceId = androidInfo.id; // Unique Android ID
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        return deviceId = iosInfo.identifierForVendor; // Unique iOS ID
      }
    } catch (e) {
      debugPrint("Error fetching device ID: $e");
    }
    return null;
  }
}
