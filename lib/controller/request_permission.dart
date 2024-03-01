import 'dart:io';

import 'package:chat_bot/logger_custom.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestMicrophonePermissions() async {
  // Request microphone permission
  PermissionStatus status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    // Handle denied or restricted permissions
    return false;
  } else {
    return true;
  }
}

Future<bool> requestStoragePermissions() async {
  //  Request storage permission only for Android version < V13
  PermissionStatus status = await Permission.storage.request();
  if (status != PermissionStatus.granted) {
    // Handle denied or restricted permissions
    return false;
  } else {
    return true;
  }
}

Future<bool> requestRecorderPermissions() async {
  // Request microphone permission
  bool statusMicrophonePermission = await requestMicrophonePermissions2();
  bool statusstoragePermission = true;

  // Request storage permission only for Android version < V13
  try {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int androidVersion = int.parse(androidInfo.version.release);
      if (androidVersion >= 13) {
        statusstoragePermission = true;
      } else {
        statusstoragePermission = await requestStoragePermissions();
      }
    }
  } catch (e) {
    CustomLogger().error('Error: $e');
    statusstoragePermission = true;
  }
  return (statusMicrophonePermission && statusstoragePermission);
}

Future<bool> requestMicrophonePermissions2() async {
  String errorMessage = '';
  // status of permission
  PermissionStatus status = await Permission.microphone.status;
  if (await (Permission.microphone.isGranted)) {
    return true;
  }

  if ((await Permission.microphone.isDenied) ||
      (await Permission.microphone.isPermanentlyDenied)) {
    // make a permission request
    await Permission.microphone.request();
    status = await Permission.microphone.status;
    // Check permission status
    if (await Permission.microphone.isGranted) {
      return true;
    } else if (await Permission.microphone.isDenied) {
      errorMessage = 'Microphone isDenied ';
      CustomLogger().error(errorMessage);
      // Future.error("Location permission denied");
      return false;
    } else if ((await Permission.microphone.isPermanentlyDenied)) {
      errorMessage = 'Microphone isPermanentlyDenied';
      CustomLogger().error(errorMessage);
      openAppSettings();
    }
  }
  return false;
}
