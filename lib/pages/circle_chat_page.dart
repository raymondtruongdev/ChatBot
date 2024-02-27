import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/components/textfield_chat_input.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class CircleChatPage extends StatefulWidget {
  const CircleChatPage({super.key});

  @override
  State<CircleChatPage> createState() => _CircleChatPageState();
}

FocusNode myfocusNode = FocusNode();

List<ChatMessage> messages = [];

class _CircleChatPageState extends State<CircleChatPage> {
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
    double watchSize = chatBotController.getWatchSize();
    return Center(
      child: ScreenUtilInit(
          designSize: const Size(390, 390),
          minTextAdapt: true,
          splitScreenMode: true,
          // Obx(
          //   () =>
          child: ClipOval(
            child: SizedBox(
              width: watchSize,
              height: watchSize,
              child: (Column(
                children: [
                  // display header of page
                  _topChat(),
                  // display all message
                  // Expanded(child: _messageList()),
                  // Container(
                  //   child: chatBotController.checkLoading().isTrue
                  //       ? _botThinking()
                  //       : (() {
                  //           if (chatBotController.messages.isNotEmpty) {
                  //             scroolDown();
                  //             if (chatBotController.errorInfo != '') {
                  //               return _botError();
                  //             } else {
                  //               return null;
                  //             }
                  //           }
                  //         })(),
                  // ),

                  // user input
                  // _userInput(),
                ],
                // )),
              )),
            ),
          )),
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

  Widget _messageList() {
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
                ? const EdgeInsets.only(left: 40, right: 10)
                : const EdgeInsets.only(left: 10, right: 40, top: 25),
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
      color: const Color(0xff1b2b33),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Image(
                height: 30,
                image: AssetImage('lib/assets/ic_mijo_logo.png'),
              ),
              SizedBox(width: 10),
              Image(
                height: 30,
                image: AssetImage('lib/assets/metaLogo.png'),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              chatBotController.resetMessageShowList();
              chatBotController.resetHistoryBot();

              setState(() {});
            },
            icon: Container(
              width: 36, // Adjust the size of the circle as needed
              height: 36, // Adjust the size of the circle as needed
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
    );
  }

  Widget _botThinking() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: SizedBox(
          height: 100,
          width: 200,
          child: Lottie.asset("lib/assets/lottie_loading_3d_spheres.json"),
        ));
  }

  Widget _botError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        height: 50,
        width: 300,
        decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Center(child: Text(chatBotController.errorInfo)),
      ),
    );
  }
}
