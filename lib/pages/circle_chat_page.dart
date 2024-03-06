import 'package:chat_bot/components/textfield_chat_input_circle.dart';
import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/request_permission.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:chat_bot/models/zalo_text_to_speech.dart';
import 'package:chat_bot/pages/setting_page.dart';
import 'package:chat_bot/pages/speech_to_text_page.dart';
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
    chatBotController.setScroolDownMessageList(scroolDownAll);
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

  void scroolDownAll() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });
  }

  void scroolDownWithErrorBanner() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  void onResetListMessages() {
    chatBotController.resetMessageShowList();
    chatBotController.resetHistoryBot();
    setState(() {});
  }

  void sendMessage() {
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

  @override
  Widget build(BuildContext context) {
    double watchSize = chatBotController.getWatchSize();
    return Obx(() => Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: chatBotController.isCircleDevice()
                ? Colors.black
                : Colors.white,
            child: Center(
              child: ScreenUtilInit(
                designSize: const Size(390, 390),
                minTextAdapt: true,
                splitScreenMode: true,
                child: ClipOval(
                  child: Container(
                    color: Colors.black,
                    width: watchSize,
                    height: watchSize,
                    child: Center(
                      child: Column(
                        children: [
                          // display header of page
                          TopChat(
                            onPressed: () => onResetListMessages,
                          ),
                          // display all message
                          Expanded(child: _messageList()),
                          const SizedBox(height: 10.0),
                          Container(
                            child: chatBotController.checkLoading().isTrue
                                ? const BotThinking()
                                : (() {
                                    if (chatBotController.messages.isNotEmpty) {
                                      scroolDownWithErrorBanner();
                                      if (chatBotController.errorInfo != '') {
                                        return const BotError();
                                      } else {
                                        return null;
                                      }
                                    }
                                  })(),
                          ),

                          // user input
                          Container(
                            child: chatBotController.checkLoading().isFalse
                                ? _userInput()
                                : Padding(
                                    padding: EdgeInsets.only(bottom: 30.w),
                                    child: Center(
                                      child: Text(
                                        '... Thinking ...',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.sp),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _messageList() {
    return ListView(
      controller: _scrollController,
      children: chatBotController.messages
          .map((message) => MessageItem(message: message))
          .toList(),
    );
  }

  Widget _userInput() {
    return TextFieldChatInputCircle(
        hintText: 'Type a message',
        obscureText: false,
        controller: _messageController,
        focusNode: myfocusNode,
        onPressed: sendMessage,
        onSubmitted: () => sendMessage(),
        onPressedVoiceChat: () {
          // Hide keyboard
          myfocusNode.unfocus();
          // Clear text
          _messageController.clear();
          // Show the end of message list
          scroolDownAll();

          // Check and Request for Recorder Permissions
          requestRecorderPermissions().then((value) {
            if (value == true) {
              // // Go to VoiceFileTextBotController
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const VoiceFileTextBotController(),
              //     settings: const RouteSettings(name: 'VoiceFileTextBotController'),
              //   ),
              // );

              // Go to SpeechToTextPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpeechToTextPage(),
                  settings: const RouteSettings(name: 'SpeechToTextPage'),
                ),
              );
            }
          });
        });
  }
}

class TopChat extends StatelessWidget {
  final Function onPressed;
  const TopChat({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Container(
        height: 65.w,
        color: const Color(0xff145503),
        child: Padding(
          padding: EdgeInsets.only(top: 25.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xff0B9AC5), // Border color
                          width: 2.0.w, // Border width
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Go to SettingPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                              settings:
                                  const RouteSettings(name: 'SettingPage'),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(
                              0), // Remove button elevation
                          backgroundColor: MaterialStateProperty.all(Colors
                              .transparent), // Set background color to transparent
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        child: const Image(
                          image: AssetImage('lib/assets/ic_mijo_logo.png'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.w),
                    child: Image(
                      width: 120.w,
                      image: const AssetImage('lib/assets/metaLogo.png'),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 2.0.w, // Border width
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: onPressed(),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(
                            0), // Remove button elevation
                        backgroundColor: MaterialStateProperty.all(Colors
                            .transparent), // Set background color to transparent
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 30.w,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final ChatMessage message;
  const MessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Container(
        margin: (message.role == Role.user)
            ? EdgeInsets.only(top: 10.w)
            : const EdgeInsets.only(top: 0),
        child: Stack(
          alignment: (message.role == Role.user)
              ? Alignment.topRight
              : Alignment.topLeft,
          children: [
            Container(
              margin: (message.role == Role.user)
                  ? EdgeInsets.only(left: 80.w, right: 50.w)
                  : EdgeInsets.only(left: 40.w, right: 80.w, top: 30.w),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.w),
                  topLeft:
                      Radius.circular((message.role == Role.user) ? 20.w : 0),
                  bottomRight:
                      Radius.circular((message.role == Role.user) ? 0 : 20.w),
                  topRight: Radius.circular(20.w),
                ),
                color: (message.role == Role.user)
                    ? Colors.deepPurple
                    : const Color(0xff095BBC),
              ),
              child: TextButton(
                onPressed: () {
                  // Call your function here
                  // yourFunction();
                  print('hello');
                  ZaloTextToSpeech.processTextToSpeech((message.text));
                },
                child: Text(message.text,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              child: !(message.role == Role.user)
                  ? Container(
                      margin: EdgeInsets.only(left: 30.w),
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('lib/assets/m_assistant_120.png'),
                            fit: BoxFit.fill),
                      ))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class BotThinking extends StatelessWidget {
  const BotThinking({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: SizedBox(
        height: 100.w,
        width: 200.w,
        child: Lottie.asset("lib/assets/lottie_loading_3d_spheres.json"),
      ),
    );
  }
}

class BotError extends StatelessWidget {
  const BotError({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: 5.0.w),
        child: Container(
          height: 30.w,
          width: 200.w,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.all(Radius.circular(30.w))),
          child: Center(child: Text(chatBotController.errorInfo)),
        ),
      ),
    );
  }
}
