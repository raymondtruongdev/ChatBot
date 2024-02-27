import 'dart:async';

import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:chat_bot/models/open_ai_bot.dart';
import 'package:get/state_manager.dart';

class ChatBotController extends GetxController {
  @override
  void onInit() {
    if (_isLoading.isTrue) {
    } else {}
    super.onInit();
    resetHistoryBot();
  }

  // ==================== Variables ============================================
  final RxBool _isLoading = false.obs;
  List<ChatMessage> messages = [];
  var _historyOpenAIMessage = [];
  String errorInfo = '';

  late double _watchSize = 1080.0;
  double widthScreenDevice = 0.0;
  double heightScreenDevice = 0.0;
  double _scaleRatio = 0.0;
  bool _isCircleDevice = false;

// ==================== Getters ============================================
  RxBool checkLoading() => _isLoading;
  double getWatchSize() => _watchSize;
  double getScaleRatio() => _scaleRatio;
  bool isCircleDevice() => _isCircleDevice;

  // ==================== Uitlilty Functions ============================================
// Add new message to the list to show in Chat View
  List<ChatMessage> addMessageShowList(ChatMessage newUserMessage) {
    messages.add(newUserMessage);
    return messages;
  }

  List<ChatMessage> resetMessageShowList() {
    messages = [];
    return messages;
  }

  void resetHistoryBot() {
    _historyOpenAIMessage = OpenAIBot.resetHistoryOpenAIMessage();
  }

  void addHistoryBot(ChatMessage message) {
    _historyOpenAIMessage = OpenAIBot.addHistoryOpenAIMessage(
        historyOpenAIMessage: _historyOpenAIMessage,
        role: message.role,
        content: message.text);
  }

// Make a reequest to ChatBot
  void sendChatBot(ChatMessage newUserMessage) async {
    errorInfo = '';
    _isLoading.value = true;

    addHistoryBot(newUserMessage);
    try {
      final messageBot = await OpenAIBot.processData(_historyOpenAIMessage);
      if (messageBot != null) {
        // Add new ChatBot message to messages list
        addMessageShowList(messageBot);
        // Add new ChatBot message to HistoryBot list
        addHistoryBot(messageBot);
      } else {
        errorInfo = 'Cannot connect to the server.';
      }
      _isLoading.value = false;
    } catch (e) {
      CustomLogger().error('An error occurred: $e');
      _isLoading.value = false;
    }
  }

  void updateWatchSize(double widthScreen, double heightScreen) {
    final CustomLogger logger = CustomLogger();
    // If widthScreen <       0   : _watchSize = 0;
    // If widthScreen > maxScreen : _watchSize = maxScreen;
    // If 0 <= widthScreen <= maxScreen : _watchSize = widthScreen;
    double maxScreen = 1080.0;
    _watchSize = widthScreen.clamp(0, maxScreen);

    double defaultWatchSize = 390;

    _scaleRatio = _watchSize.toDouble() / defaultWatchSize;

    if (heightScreen <= widthScreen * 1.1) {
      // heigth < 110% of width => circle face
      _isCircleDevice = true;
      // logger.warning('This is circle device');
    } else {
      _isCircleDevice = false;
      // logger.warning('This is NOT circle device');
    }
    // logger.debug('widthScreen Controller: $widthScreen');
    // logger.debug('heightScreen Controller: $heightScreen');
    // logger.debug('ScreenIsCircle Controller: $_isCircleDevice()');

    widthScreenDevice = widthScreen;
    heightScreenDevice = heightScreen;
  }
}
