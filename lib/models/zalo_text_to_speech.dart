import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class ZaloTextToSpeech {
  static Future<String?> processTextToSpeech(String text) async {
    String onlineMode = 'online';
    String? audioPath = '';
    switch (onlineMode) {
      case 'online':
        audioPath = await sendTextToZalo(text);
        break;
      case 'offline':
        // audioPath = await sendTextToZalo(text);
        break;
    }
    // playAudioHttp(
    //     "https://chunk.lab.zalo.ai/bcb3b82f5a46b318ea57/bcb3b82f5a46b318ea57");
    return audioPath;
  }
}

Future<String?> sendTextToZalo(String text) async {
  String audioPath = '';
  String apiKey = 'i2UqfgNK9J6i2hHkJjEjMRi23kCJGql3';
  String url = 'https://api.zalo.ai/v1/tts/synthesize';
  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'apikey': apiKey,
  };

  Map<String, String> body = {
    // 'input': 'Xin chào, tôi có thể giúp gì cho bạn?',
    'input': text,
    'encode_type': '0',
    'speaker_id': '1',
    'speed': '0.8',
  };
/*
curl \
  -H "apikey: kAW0DUygvKQR9sAeIpztRu50TB87E18x" \
  --data-urlencode "input=Xin chào, tôi có thể giúp gì cho bạn?" \
  -d "speaker_id=4" \
  -d "speed=0.8" \
  -X POST https://api.zalo.ai/v1/tts/synthesize
*/

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      String zaloAudioUrl = jsonMap['data']['url'] ?? '';
      CustomLogger().debug(zaloAudioUrl);

      if (zaloAudioUrl.isNotEmpty) {
        // Dowload file to phone then play
        // await Future.delayed(const Duration(seconds: 1));
        // audioPath = await makeDownloadVoiceZaloRequest(zaloAudioUrl);
        // playAudio(audioPath);

        //  Play directly in http
        playAudioHttp(zaloAudioUrl);
      }
      return audioPath;
    } else {
      CustomLogger().error('Request failed: ${response.statusCode}');
      return '';
    }
  } catch (e) {
    CustomLogger().error('Error sending request: $e');
    return '';
  }
}

Future<String> makeDownloadVoiceZaloRequest(String zaloAudioUrl) async {
  try {
    // Start getting voice file and save to storage
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      CustomLogger().error('Can not found directory to save recording');
      return '';
    } else {
      // Save file here
      // /storage/emulated/0/Android/data/com.mijo.chatbot/files/zalo_voice.wav
      String savePath = '${directory.path}/zalo_voice.wav';
      // await deleteFile(savePath);
      try {
        // String url =
        //     'https://chunk.lab.zalo.ai/d0c64e63af0a46541f1b/d0c64e63af0a46541f1b';

        CustomLogger().error('Make download Zalo voice file: $zaloAudioUrl');
        String url = zaloAudioUrl;
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await saveToFile(response.bodyBytes, savePath);
          CustomLogger().debug('File saved at: $savePath');
          return savePath;
        } else {
          CustomLogger()
              .error('Request  download Zalo  failed: ${response.statusCode}');
          return '';
        }
      } catch (err) {
        CustomLogger().error('Error in save Zalo voice file: $err');
        return '';
      }
    }
  } catch (err) {
    CustomLogger().error('Error stopping recording: $err');
    return '';
  }
}

Future<void> saveToFile(List<int> bytes, String path) async {
  final file = File(path);
  await file.writeAsBytes(bytes);
}

Future<void> deleteFile(String filePath) async {
  try {
    // Create a File instance
    File file = File(filePath);
    // Check if the file exists
    bool exists = await file.exists();
    if (exists) {
      // Delete the file
      await file.delete();
    }
  } catch (e) {
    CustomLogger().error('Error occurred while deleting the file: $e');
  }
}

Future<void> playAudio(String audioPath) async {
  final player = chatBotController.player;
  await player.setAudioSource(AudioSource.file(audioPath));
// Schemes: (https: | file: | asset: )
  player.play(); // Play without waiting for completion
}

Future<void> playAudioHttp(String audioPath) async {
  final player = chatBotController.player;
  await player.setAudioSource(AudioSource.uri(Uri.parse(audioPath)));
// Schemes: (https: | file: | asset: )
  player.play(); // Play without waiting for completion
}
