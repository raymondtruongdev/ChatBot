import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/components/textfield_chat_input.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

FocusNode myfocusNode = FocusNode();

List<ChatMessage> messages = [];

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myfocusNode.addListener(() {
      if (myfocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () => scroolDown());
      }
    });
  }

  @override
  void dispose() {
    myfocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scroolDown() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - keyboardHeight + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // display header of page
        _topChat(),
        // display all message
        Expanded(child: _buildMessageList()),

        // user input
        _userInput(),
      ],
    );
  }

  sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // Add new user's message to messages list
      ChatMessage newUserMessage = ChatMessage(
        text: _messageController.text,
        user: 'username',
        createdAt: DateTime.now(),
        role: Role.user,
      );
      chatBotController.addMessageShowList(newUserMessage);
      // Make a reequest to ChatBot
      chatBotController.sendChatBot(newUserMessage);
    }

    // Clear Controller
    _messageController.clear();

    // Hide keyboard
    myfocusNode.unfocus();

    // Scroll the ListView to the last message
    Future.delayed(
        const Duration(milliseconds: 200),
        () => {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
              )
            });

    setState(() {});
  }

  Widget _buildMessageList() {
    return ListView(
      controller: _scrollController,
      children: chatBotController.messages
          .map((message) => _messageItem(message))
          .toList(),
    );
  }

  Widget _messageItem(var message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: (message.role == Role.user)
            ? Alignment.topRight
            : Alignment.topLeft,
        children: [
          Container(
            margin: (message.role == Role.user)
                ? const EdgeInsets.only(right: 10)
                : const EdgeInsets.only(left: 10, top: 25, right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(20),
                topLeft: Radius.circular((message.role == Role.user) ? 20 : 0),
                bottomRight:
                    Radius.circular((message.role == Role.user) ? 0 : 20),
                topRight: const Radius.circular(20),
              ),
              color: (message.role == Role.user)
                  ? Colors.deepPurple
                  : Colors.green.shade800,
            ),
            child:
                Text(message.text, style: const TextStyle(color: Colors.white)),
          ),
          Container(
            child: !(message.role == Role.user)
                ? Container(
                    margin: const EdgeInsets.only(left: 5),
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('lib/assets/robot256.png'),
                          fit: BoxFit.fill),
                    ))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _userInput() {
    return TextFieldChatInput(
      hintText: 'Type a message',
      obscureText: false,
      controller: _messageController,
      focusNode: myfocusNode,
      onPressed: sendMessage,
    );
  }

  Widget _topChat() {
    return Container(
      height: 60,
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/assets/openai.png'),
                        fit: BoxFit.fill),
                  )),
              const SizedBox(width: 10),
              const Text(
                'OpenAI Bot',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  chatBotController.resetMessageShowList();
                  chatBotController.resetHistoryBot();

                  setState(() {});
                },
                icon: Container(
                  width: 50, // Adjust the size of the circle as needed
                  height: 50, // Adjust the size of the circle as needed
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue, // Adjust the color as needed
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
