import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/voice_to_text_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

class VoiceToTextPage extends StatefulWidget {
  const VoiceToTextPage({super.key});

  @override
  State<VoiceToTextPage> createState() => _VoiceToTextPageState();
}

class _VoiceToTextPageState extends State<VoiceToTextPage> {
  String status = RecordStatus.none;
  String textVoiceContent = '';
  String infoText = '';
  TextEditingController textController = TextEditingController();

  late stt.SpeechToText _speech;
  late bool _isListening = false;
  late double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _isListening = false;
    onClick(RecordStatus.none);
  }

  // Make a messeage and send to ChatBot
  void sendMessage(String text) {
    if (text.isNotEmpty) {
      // Add new user's message to messages list
      ChatMessage newUserMessage = ChatMessage(
        text: text,
        user: 'username',
        createdAt: DateTime.now(),
        role: Role.user,
      );
      chatBotController.addMessageShowList(newUserMessage);
      // Make a reequest to ChatBot
      chatBotController.sendChatBot(newUserMessage);
    }
  }

  void onClick(String newSatus) async {
    switch (newSatus) {
      case RecordStatus.exit:
        Navigator.pop(context);
        return;

      case RecordStatus.none:
        break;

      case RecordStatus.refresh:
        textVoiceContent = '';

        break;

      case RecordStatus.send:
        // Return main Chat page
        String str = textController.text;
        sendMessage(str);

        break;

      case RecordStatus.recording:
        status = RecordStatus.recording;
        break;

      default:
    }

    setState(() {});
  }

  void autoReCognition() async {
    textVoiceContent = '';
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) async {
          CustomLogger().debug('onStatus: $val');
        },
        onError: (val) => CustomLogger().error('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            textVoiceContent = val.recognizedWords;
            CustomLogger().info(textVoiceContent);
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
      _speech.stop();
      CustomLogger().debug('Speech stopped');
    }
  }

  @override
  Widget build(BuildContext context) {
    double watchSize = chatBotController.getWatchSize();
    // status = RecordStatus.none;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: chatBotController.isCircleDevice() ? Colors.black : Colors.white,
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
                child: Column(children: [
                  const HeaderVoice(),
                  SizedBox(
                    height: 10.w,
                  ),
                  InfomationBanner(text: 'Infomation Banner', status: status),
                  SizedBox(
                    height: 10.w,
                  ),
                  // Show text result
                  Expanded(
                      child: ContentVoice(
                    controller: textController,
                    text: textVoiceContent,
                    status: status,
                  )),
                  SizedBox(height: 10.0.w),
                  // Control bar
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.w),
                    child: Container(
                      height: 50.w,
                      width: 200.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(30.w)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Button(
                              color: Colors.red,
                              iconData: Icons.arrow_back,
                              onPressed: () {
                                onClick(RecordStatus.exit);
                              },
                            ),
                            Button(
                              color: Colors.blueGrey,
                              iconData: Icons.refresh,
                              onPressed: () {
                                onClick(RecordStatus.refresh);
                              },
                            ),
                            Button(
                              color: Colors.green,
                              iconData: Icons.mic,
                              onPressed: () {
                                onClick(RecordStatus.recording);
                              },
                            ),
                            Button(
                              color: Colors.blueAccent,
                              iconData: Icons.arrow_upward,
                              onPressed: () {
                                onClick(RecordStatus.send);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderVoice extends StatelessWidget {
  const HeaderVoice({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 390),
        minTextAdapt: true,
        splitScreenMode: true,
        child: Container(
            width: double.infinity,
            height: 80.w,
            color: const Color(0xff145503),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30.w),
                child: Text(
                  'Speech Recognition',
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                ),
              ),
            )));
  }
}

class InfomationBanner extends StatelessWidget {
  final String text;
  final String status;
  const InfomationBanner({super.key, this.text = '', required this.status});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 390),
        minTextAdapt: true,
        splitScreenMode: true,
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(left: 50.w, right: 50.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.w),
                      topLeft: Radius.circular(20.w),
                      bottomRight: Radius.circular(20.w),
                      topRight: Radius.circular(20.w),
                    ),
                    color: Colors.black),
                child: Text(text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold))),
          ],
        ));
  }
}

class ContentVoice extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final String status;
  const ContentVoice(
      {super.key,
      this.text = '',
      required this.controller,
      required this.status});

  @override
  Widget build(BuildContext context) {
    controller.text = text;

    return ScreenUtilInit(
        designSize: const Size(390, 390),
        minTextAdapt: true,
        splitScreenMode: true,
        child: Column(
          // alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 50.w, right: 50.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.w),
                    topLeft: Radius.circular(20.w),
                    bottomRight: Radius.circular(20.w),
                    topRight: Radius.circular(20.w),
                  ),
                  color: Colors.white),
              child: TextField(
                  // onSubmitted: (value) => onSubmitted(),
                  controller: controller,
                  // focusNode: focusNode,
                  maxLines: 4,
                  minLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.black,
                    // hintText: 'Type a message',
                  )),
            ),
          ],
        ));
  }
}

class Button extends StatelessWidget {
  final Function onPressed;
  final IconData iconData;
  final Color color;

  const Button({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Container(
          width: 40.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: IconButton(
            onPressed: () => onPressed(),
            icon: Icon(iconData, color: Colors.white),
          )),
    );
  }
}
