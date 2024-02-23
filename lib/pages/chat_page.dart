import 'package:chat_bot/consts.dart';
import 'package:chat_bot/models/face_book_bot.dart';
import 'package:chat_bot/components/my_textfield.dart';
import 'package:chat_bot/components/textfield_chat_input.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

FocusNode myfocusNode = FocusNode();

List<Map<String, dynamic>> messages = [];

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
    _scrollController.animateTo(
      _scrollController.position.devicePixelRatio,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // display all message
        Expanded(child: _buildMessageList()),

        // user input
        _buildUserInput(),
      ],
    );
  }

  sendMessage() {
    if (_messageController.text.isNotEmpty) {
      //send message
      // print('Send message');

      addMessage(
        message: ChatMessage(
          text: 'who are you',
          user: 'username',
          createdAt: DateTime.now(),
          role: 'user',
        ),
        isUserMessage: true,
      );

      FaceBookBot data = FaceBookBot.fromJson(jsStrBot1);

      List<Choice> choices = data.choices ?? [];
      String content = choices[0].message!.content!;
      String role = choices[0].message!.role!;

      addMessage(
        message: ChatMessage(
          text: content,
          user: 'FacebookBot',
          createdAt: DateTime.now(),
          role: role,
        ),
        isUserMessage: false,
      );
    }

    // Clear Controller
    _messageController.clear();

    // Hide keyboard
    myfocusNode.unfocus();

    // Scroll the ListView to the last message

    setState(() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  void addMessage({ChatMessage? message, bool isUserMessage = false}) {
    messages.add({"message": message, "isUserMessage": isUserMessage});
  }

  Widget _buildMessageList() {
    return ListView(
      controller: _scrollController,
      children: messages.map((message) => _buildMessageItem(message)).toList(),
    );
  }

  Widget _buildMessageItem(var message) {
    return Container(
      alignment: message["isUserMessage"]
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(20),
            topLeft: const Radius.circular(20),
            bottomRight: Radius.circular(message["isUserMessage"] ? 0 : 20),
            topRight: Radius.circular(message["isUserMessage"] ? 20 : 0),
          ),
          color: message["isUserMessage"]
              ? Colors.deepPurple
              : Colors.green.shade800,
        ), // <- Moved the closing parenthesis here
        child: Text('${message["message"].text}', // <- Corrected message access
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Widget _buildUserInput() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: MyTextField(
  //           hintText: 'Type a message',
  //           obscureText: false,
  //           controller: _messageController,
  //           focusNode: myfocusNode,
  //         ),
  //       ),
  //       Container(
  //         decoration:
  //             const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
  //         margin: const EdgeInsets.only(right: 25),
  //         child: IconButton(
  //           onPressed: sendMessage,
  //           icon: const Icon(
  //             Icons.arrow_upward,
  //             color: Colors.white,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget _buildUserInput() {
    return TextFieldChatInput(
      hintText: 'Type a message',
      obscureText: false,
      controller: _messageController,
      focusNode: myfocusNode,
      onPressed: sendMessage,
    );
  }
}
