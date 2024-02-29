import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/controller/request_permission.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/pages/voice_recognition_page.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// curl -X POST -F "file=@sample/output.wav;type=audio/wav" http://192.168.1.23:5000/speech_to_text

// {
//   "text": "m\u1ed9t hai ba b\u1ed1n n\u0103m s\u00e1u b\u1ea3y t\u00e1m ch\u00edn m\u01b0\u1eddi."
// }
Future<String> demoDelayReturnText(String text) async {
  await Future.delayed(const Duration(milliseconds: 3000));
  return text;
}

class VoiceToText {
  static Future<String> processVoiceToText(String filePath) async {
    // return demoDelayReturnText(filePath);
    // Draft
    String strOutput = '';
    String filename = filePath;
    String url = 'http://192.168.1.23:5000/speech_to_text';
    http.MultipartRequest request;
    try {
      request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filename,
          filename: filename.split("/").last,
        ),
      );
    } catch (e) {
      CustomLogger().error('Error in make http request: ${e.toString()}');
      return '';
    }

    try {
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        var response = await http.Response.fromStream(streamedResponse);
        CustomLogger().debug('Response: ${response.body}');
        var jsStr = response.body;
        // Parse the JSON string
        Map<String, dynamic> data = jsonDecode(jsStr);
        // Extract text
        strOutput = data['text'];
      } else {
        CustomLogger().error('Error: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      CustomLogger().error('Error: $e');
    }
    return strOutput;
  }

  static Future<bool> startRecording() async {
    // Request microphone permission
    bool status = await requestMicrophonePermissions();
    if (status == false) {
      return false;
    }
    // Request storage permission only for Android version < V13
    // status = await requestStoragePermissions();
    // if (status == false) {
    //   return false;
    // }

    // Start Recording
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      CustomLogger().error('Can not found directory to save recording');
      return false;
    } else {
      // Save file here
      // /storage/emulated/0/Android/data/com.mijo.chatbot/files/example.aac
      String filePath = '${directory.path}/example.aac';
      try {
        voiceBotController.soundRecorder.openRecorder();
        await voiceBotController.soundRecorder.startRecorder(toFile: filePath);
        return true;
      } catch (err) {
        CustomLogger().error('Error starting recording: $err');
        return false;
      }
    }
  }

  static Future<String> stopRecording() async {
    var filePath = '';
    // Stop recording
    try {
      filePath = await voiceBotController.soundRecorder.stopRecorder() ?? '';
      voiceBotController.soundRecorder.closeRecorder();
      CustomLogger().debug('Recording saved to: $filePath');
      return filePath;
    } catch (err) {
      CustomLogger().error('Error stopping recording: $err');
      return '';
    }
  }
}
