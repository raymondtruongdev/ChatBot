import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:chat_bot/models/open_ai_bot.dart';
import 'package:get/state_manager.dart';

class ChatBotController extends GetxController {
  final RxBool _isLoading = true.obs;
  List<ChatMessage> messages = [];
  var _historyOpenAIMessage = [];

  RxBool checkLoading() => _isLoading;

  @override
  void onInit() {
    if (_isLoading.isTrue) {
    } else {}
    super.onInit();
    resetHistoryBot();
  }

// Add new message to the list to show in Chat View
  List<ChatMessage> addMessageShowList(ChatMessage newUserMessage) {
    messages.add(newUserMessage);
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
    addHistoryBot(newUserMessage);
    try {
      final messageBot = await OpenAIBot.processData(_historyOpenAIMessage);
      if (messageBot != null) {
        // Add new ChatBot message to messages list
        addMessageShowList(messageBot);
        // Add new ChatBot message to HistoryBot list
        addHistoryBot(messageBot);
      } else {
        CustomLogger().error('Cannot connect to the server.');
      }
    } catch (e) {
      CustomLogger().error('An error occurred: $e');
    }
  }
}