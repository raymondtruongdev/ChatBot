import 'dart:io';
import 'package:chat_bot/logger_custom.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> writeTextToFile(String text) async {
  String filePath = '';
  bool isPermissionGranted = false;
  // Request storage permission
  PermissionStatus status = await Permission.storage.request();
  if (status != PermissionStatus.granted) {
    // Handle denied or restricted permissions
    isPermissionGranted = false;
  } else {
    isPermissionGranted = true;
  }
  if (!isPermissionGranted) {
    await Future.delayed(const Duration(milliseconds: 3000));
    Directory? directory = await getExternalStorageDirectory();
    final Directory tempDir = await getTemporaryDirectory();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final Directory? downloadsDir = await getDownloadsDirectory();

    CustomLogger().debug('directory: ${directory?.path}');
    CustomLogger().debug('tempDir: ${tempDir.path}');
    CustomLogger().debug('appDocumentsDir: ${appDocumentsDir.path}');
    CustomLogger().debug('downloadsDir: ${downloadsDir?.path}');

    if (directory != null) {
      filePath = '${directory.path}/my_text_file.txt';
      File file = File(filePath);
      await file.writeAsString(text);
    } else {
      filePath = '';
      CustomLogger().error('Error accessing directory');
    }
  }
  return filePath;
}
