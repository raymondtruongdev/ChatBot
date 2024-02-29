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
