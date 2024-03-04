import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/controller/request_permission.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/pages/voice_file_text_page.dart';
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

class VoiceFileText {
  static Future<String> processVoiceToText(String filePath) async {
    // return demoDelayReturnText(filePath);
    // Draft
    String strOutput = '';
    String filename = filePath;
    // filename =
    //     '/storage/emulated/0/Android/data/com.mijo.chatbot/files/trungle.wav';
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
        // Parse the JSON string
        Map<String, dynamic> data = jsonDecode(response.body);
        // Extract text
        strOutput = data['text'];
      } else {
        CustomLogger().error('Error: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      CustomLogger().error('Error: $e');
      // Demo return data when error to bypass process
      // String jsonData =
      //     '{"text": "m\\u1ed9t hai ba b\\u1ed1n n\\u0103m s\\u00e1u b\\u1ea3y t\\u00e1m ch\\u00edn m\\u01b0\\u1eddi."}';
      // Map<String, dynamic> data = jsonDecode(jsonData);
      // strOutput = data['text'];
    }
    return strOutput;
  }

  static Future<String> startRecording() async {
    // Request microphone permission
    // bool status = await requestMicrophonePermissions();

    // Check and Request for Recorder Permissions
    bool status = await requestRecorderPermissions();
    if (status == false) {
      return '';
    }

    // Start Recording
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      CustomLogger().error('Can not found directory to save recording');
      return '';
    } else {
      // Save file here
      // /storage/emulated/0/Android/data/com.mijo.chatbot/files/example.aac
      String filePath = '${directory.path}/example.wav';
      try {
        voiceBotController.soundRecorder.openRecorder();
        await voiceBotController.soundRecorder.startRecorder(toFile: filePath);
        return filePath;
      } catch (err) {
        CustomLogger().error('Error starting recording: $err');
        return '';
      }
    }
  }

  static Future<String> stopRecording(String voiceFilePath) async {
    // voiceFilePath: this a a path we set when we start 'startRecording'
    // filePathFromStopRecorder: this a a path we get when we call 'stopRecorder'
    // If we set file type is 'aac'(e.g 'example.aac'): filePathFromStopRecorder will the same with voiceFilePath, and saved 'example.aac' succesfully
    // If we set file type is 'wav'(e.g 'example.wav'): filePathFromStopRecorder allways return empty, but it still saved 'example.wav' succesfully. Maybe there is bug in 'flutter_sound' package
    //
    //Stop recorder, if there is error in stopping process, we set voiceFilePath is empty
    try {
      var filePathFromStopRecorder =
          await voiceBotController.soundRecorder.stopRecorder() ?? '';
      voiceBotController.soundRecorder.closeRecorder();
      CustomLogger()
          .error('File Path when call StopRecorder: $filePathFromStopRecorder');
    } catch (err) {
      CustomLogger().error('Error stopping recording: $err');
      voiceFilePath = '';
    }
    return voiceFilePath;
  }
}
