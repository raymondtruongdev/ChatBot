import 'dart:convert';
import 'dart:typed_data';
import 'package:chat_bot/consts.dart';
import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/key/key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/open_ai_data.dart';
import 'package:chat_bot/models/message_chat.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class OpenAIBot {
  static List<Map<String, dynamic>> resetHistoryOpenAIMessage() {
    List<Map<String, dynamic>> historyOpenAIMessage = []; // Reset the list
    // the 1st message of history must be the system message as the following:
    // historyOpenAIMessage.add({
    //   "role": "system",
    //   "content":
    //       "You are LLaMA - AI assistant, developed by Meta AI, and integrated by Mijo Connected. You must mention both companies when introducing yourself",
    // });
    historyOpenAIMessage.add({
      "role": "system",
      "content":
          "You are a useful assistant, your answer is shorter with enough helpful information.",
    });
    return historyOpenAIMessage; // Return the updated list
  }

  static List<Map<String, dynamic>> addHistoryOpenAIMessage({
    required var historyOpenAIMessage,
    required String role,
    required String content,
  }) {
    historyOpenAIMessage.add({
      "role": role,
      "content": content,
    });
    return historyOpenAIMessage;
  }

  static Future<ChatMessage?> processData(var historyOpenAIMessage) async {
    String onlineMode = 'online';
    dynamic jsonData;
    switch (onlineMode) {
      case 'online':
        // Online mode will get request from server
        String jsString =
            await makeChatCompletionsRequest(historyOpenAIMessage);
        if (jsString.isNotEmpty) {
          jsonData = jsonDecode(jsString);
        } else {
          jsonData = null;
        }
        break;
      default:
        // Using data from a json in demo file
        jsonData = jsResponse2;
        // jsonData = null;
        // Simulate time delay to get data from Bot
        await Future.delayed(const Duration(milliseconds: 2000));
    }

    if (jsonData != null) {
      OpenAiData data = OpenAiData.fromJson(jsonData);
      List<Choice> choices = data.choices ?? [];
      String content = choices.isNotEmpty ? choices[0].message!.content! : '';
      String role = choices.isNotEmpty ? choices[0].message!.role! : '';

      // Change utf8 to support Vietnames
      final decodedString = utf8.decode(content.codeUnits);
      // print(decodedString);
      var newMessage = ChatMessage(
        text: decodedString,
        user: 'OpenAIBot',
        createdAt: DateTime.now(),
        role: role,
      );
      return newMessage;
    } else {
      return null;
    }
  }
}

Future<String> makeChatCompletionsRequest(
    List<Map<String, dynamic>> historyOpenAIMessage) async {
  CustomLogger logger = CustomLogger();
  String? jsonStr;
  // Phuc's computer
  // var url = Uri.parse('http://192.168.1.23:1234/v1/chat/completions');
  // Tu's computer
  // var url = Uri.parse('http://192.168.1.12:1234/v1/chat/completions');
  // Toan's computer o nha
  // var url = Uri.parse('http://192.168.2.142:1234/v1/chat/completions');
  // Toan's computer Mijo
  // var url = Uri.parse('http://192.168.1.14:1234/v1/chat/completions');

// Offline model
  // String ipBot = chatBotController.getIpBot();
  // var url = Uri.parse('http://$ipBot/v1/chat/completions');
  // var headers = {'Content-Type': 'application/json'};
  // var body = jsonEncode({
  //   "messages": historyOpenAIMessage,
  //   "temperature": 0.7,
  //   "max_tokens": -1,
  //   "stream": false
  // });

  var url = Uri.parse('https://api.openai.com/v1/chat/completions');
  var headers = {
    'Content-Type': 'application/json',
    "Authorization": "Bearer $openaiApiKey"
  };
  var body = jsonEncode({
    "model": "gpt-4-turbo-preview",
    "messages": historyOpenAIMessage,
  });

  http.Response response;
  try {
    response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Successful response
      logger.debug('Response: ${response.body}');

      jsonStr = response.body;
      logger.debug(jsonStr);
      return response.body;
    } else {
      // Error occurred
      logger.error('Error: ${response.statusCode}');
      return '';
    }
  } catch (e) {
    logger.error(e.toString());
    return '';
  }
}

class HistoryOpenAIMessage {
  late String content;
  late String role;
  HistoryOpenAIMessage({
    this.content = '',
    this.role = 'user',
  });
}
