import 'dart:convert';
import 'dart:io';
import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class ZaloTextToSpeech {
  static Future<String?> processTextToSpeech(String text) async {
    try {
      String method = 'method2';
      switch (method) {
        case 'method1': // Reques link => download file to phone => play file
          String zaloAudioUrl = await sendTextToZalo(text);
          String audioPath = await downloadAudioFileZalo(zaloAudioUrl);
          playAudioInDevice(audioPath);
          return audioPath;

        case 'method2': // Reques link => Play file in web
          String zaloAudioUrl = await sendTextToZalo(text);
          playAudioHttp(zaloAudioUrl);
          // playAudioHttp(
          //     "https://chunk.lab.zalo.ai/d0c64e63af0a46541f1b/d0c64e63af0a46541f1b");
          return zaloAudioUrl;
      }
    } catch (e) {
      return Future.error('Error module processTextToSpeech Zalo: $e');
    }
    return null;
  }
}

// Send a text to Zalo and recive an audio link
Future<String> sendTextToZalo(String text) async {
  /* 
  // Example request to Zalo:
curl \
  -H "apikey: kAW0DUygvKQR9sAeIpztRu50TB87E18x" \
  --data-urlencode "input=Xin chào, tôi có thể giúp gì cho bạn?" \
  -d "speaker_id=4" \
  -d "speed=0.8" \
  -X POST https://api.zalo.ai/v1/tts/synthesize

  // Example Return from Zalo:
  var jsonStr = {"data":{"url":"https://chunk.lab.zalo.ai/d0c64e63af0a46541f1b/d0c64e63af0a46541f1b"},"error_message":"Successful.","error_code":0}
*/

  String apiKey = 'i2UqfgNK9J6i2hHkJjEjMRi23kCJGql3';
  String url = 'https://api.zalo.ai/v1/tts/synthesize';
  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'apikey': apiKey,
  };

  Map<String, String> body = {
    'input': text,
    'encode_type': '0',
    'speaker_id': '1',
    'speed': '0.8',
  };
  // https://zalo.ai/docs/api/text-to-audio-converter

  http.Response response;
  try {
    response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  } catch (e) {
    return Future.error('Error http post: $e');
  }

  if (response.statusCode == 200) {
    try {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      String zaloAudioUrl = jsonMap['data']['url'] ?? '';
      return zaloAudioUrl;
    } catch (e) {
      return Future.error('Error in parse json: $e');
    }
  } else {
    // Zalo server return a response.statusCode != 200
    return Future.error('Zalo service error: ${response.statusCode}');
  }
}

// Dowload file to phone and return file_path if success
Future<String> downloadAudioFileZalo(String zaloAudioUrl) async {
  Directory? directory;
  // Get external storage directory
  try {
    // Start getting voice file and save to storage
    directory = await getExternalStorageDirectory();
  } catch (err) {
    return Future.error('Error getting external storage: $err');
  }

  if (directory == null) {
    return Future.error('Can not found directory to save file');
  }
  // Save file here
  // /storage/emulated/0/Android/data/com.mijo.chatbot/files/zalo_voice.wav
  String savePath = '${directory.path}/zalo_voice.wav';
  // await deleteFile(savePath); // Delete old file if exist
  try {
    // String url =
    //  'https://chunk.lab.zalo.ai/d0c64e63af0a46541f1b/d0c64e63af0a46541f1b';
    String url = zaloAudioUrl;
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await saveToFile(response.bodyBytes, savePath);
      return savePath;
    } else {
      // Zalo server return a response.statusCode != 200
      return Future.error('Zalo service error: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Error in http get: $e');
  }
}

// Save a file from internet to phone
Future<void> saveToFile(List<int> bytes, String path) async {
  try {
    final file = File(path);
    await file.writeAsBytes(bytes);
  } catch (e) {
    return Future.error("Failed saving file: $e");
  }
}

// Delete a file in phone
Future<void> deleteFile(String filePath) async {
  try {
    // Create a File instance
    File file = File(filePath);
    // Check if the file exists
    bool exists = await file.exists();
    if (exists) {
      // Delete the file
      file.delete();
    }
  } catch (e) {
    return Future.error("Error in deleting the file: $e");
  }
}

// Play an audio file in device
Future<void> playAudioInDevice(String audioPath) async {
  // playAudioInDevice(
  //   "/storage/emulated/0/Android/data/com.mijo.chatbot/files/zalo_voice.wav");
  try {
    final player = chatBotController.player;
    await player.setAudioSource(AudioSource.file(audioPath));
    player.play(); // Play without waiting for completion
  } catch (e) {
    return Future.error("Error playing the audio file in device: $e");
  }
}

// Play an audio file with a link on web
Future<void> playAudioHttp(String audioPath) async {
  // playAudioHttp(
  //   "https://chunk.lab.zalo.ai/d0c64e63af0a46541f1b/d0c64e63af0a46541f1b");
  try {
    final player = chatBotController.player;
    await player.setAudioSource(AudioSource.uri(Uri.parse(audioPath)));
    player.play(); // Play without waiting for completion
  } catch (e) {
    return Future.error("Error in playing the audio file from web: $e");
  }
}
