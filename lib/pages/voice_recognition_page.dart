import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/voice_controller.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:chat_bot/models/voice_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

final VoiceBotController voiceBotController =
    Get.put(VoiceBotController(), permanent: true);

class VoiceRecognitionPage extends StatefulWidget {
  const VoiceRecognitionPage({super.key});

  @override
  State<VoiceRecognitionPage> createState() => _VoiceRecognitionPageState();
}

class _VoiceRecognitionPageState extends State<VoiceRecognitionPage> {
  String status = RecordStatus.none;
  String textVoiceContent = '';
  String infoText = '';

  @override
  void initState() {
    super.initState();
    status = RecordStatus.recording;
    onClick(status);
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
      case RecordStatus.none:
        status = RecordStatus.none;
        break;

      case RecordStatus.refresh:
        textVoiceContent = '';
        await voiceBotController.deleteFile(voiceBotController.voiceFilePath);
        status = RecordStatus.none;
        break;

      case RecordStatus.send:
        // Return main Chat page
        Navigator.pop(context);
        String str = voiceBotController.messageController.text;
        sendMessage(str);
        status = RecordStatus.none;

        break;

      case RecordStatus.recording:
        await voiceBotController.startRecording();
        status = RecordStatus.recording;
        break;

      case RecordStatus.finishRecording:
        await voiceBotController.stopRecordingAndSaveFile();
        status = RecordStatus.converting;
        onClick(status);
        break;

      case RecordStatus.converting:
        textVoiceContent = await voiceBotController.convertVoiceToText() ?? '';
        if (textVoiceContent.isEmpty) {
          infoText = 'Server Error\nPress to record again';
          status = RecordStatus.none;
        } else {
          infoText = 'Press to record';
          status = RecordStatus.finishConverting;
        }

        break;

      case RecordStatus.finishConverting:
        status = RecordStatus.finishConverting;
        break;

      default:
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double watchSize = chatBotController.getWatchSize();
    // status = RecordStatus.done;

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
                child: Column(
                  children: [
                    const HeaderVoice(),
                    // Show text result
                    Expanded(
                        child: ContentVoice(
                      controller: voiceBotController.messageController,
                      text: textVoiceContent,
                    )),
                    SizedBox(height: 10.0.w),
                    // Bot thinking and Error panel
                    Container(child: (() {
                      switch (status) {
                        case RecordStatus.recording:
                          return const BotThinking(
                            botText: 'I\'m listening',
                          );
                        case RecordStatus.converting:
                          return const BotThinking(
                            botText: 'Converting voice to text',
                          );
                        case RecordStatus.none:
                          return BotInfo(
                            botText: infoText,
                          );
                        default:
                          return null;
                      }
                    })()),

                    // Control bar
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.w),
                      child: Container(
                        height: 50.w,
                        width: ((status == RecordStatus.recording)
                            ? 160.w
                            : status == RecordStatus.converting
                                ? 160.w
                                : status == RecordStatus.finishConverting
                                    ? 120.w
                                    : status == RecordStatus.none
                                        ? 53.w
                                        : 160.w),
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
                              // Make button in Recording status
                              if (status == RecordStatus.recording) ...[
                                SizedBox(
                                  width: 90.w,
                                  child: Lottie.asset(
                                      "lib/assets/lottie_loading_teal_dots.json"),
                                ),
                                Button(
                                  iconData: Icons.pause,
                                  onPressed: () {
                                    onClick(RecordStatus.finishRecording);
                                  },
                                ),
                              ]
                              // Make button in converting  status which use to convert Voice to Text
                              else if (status == RecordStatus.converting) ...[
                                SizedBox(
                                  height: 40.w,
                                  width: 50.w,
                                  child: Lottie.asset(
                                      "lib/assets/lottie_loading_3d_spheres.json"),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 5.w),
                                  child: Text(
                                    'Converting...',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15.sp),
                                  ),
                                ),
                              ]
                              // Make button in Done status which use to show text or record again
                              else if (status ==
                                  RecordStatus.finishConverting) ...[
                                Button(
                                  iconData: Icons.refresh,
                                  onPressed: () {
                                    onClick(RecordStatus.refresh);
                                  },
                                ),
                                Button(
                                  color: Colors.blueAccent,
                                  iconData: Icons.arrow_upward,
                                  onPressed: () {
                                    onClick(RecordStatus.send);
                                  },
                                ),
                              ] // Make button in Done status which use to show text or record again
                              else if (status == RecordStatus.none) ...[
                                Button(
                                  color: Colors.green,
                                  iconData: Icons.mic,
                                  onPressed: () {
                                    onClick(RecordStatus.recording);
                                  },
                                ),
                              ],
                            ],
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

class ContentVoice extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  const ContentVoice({super.key, this.text = '', required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.text = text;
    return ScreenUtilInit(
        designSize: const Size(390, 390),
        minTextAdapt: true,
        splitScreenMode: true,
        child: (text.isEmpty)
            ? Container()
            : Column(
                // alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 10.w,
                  ),
                  SizedBox(
                    height: 30.w,
                    child: Text('You can modify here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                        )),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 50.w, right: 50.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
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
                        maxLines: 5,
                        minLines: 1,
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

class BotThinking extends StatelessWidget {
  final String botText;
  const BotThinking({super.key, required this.botText});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Column(
        children: [
          SizedBox(
            height: 10.w,
          ),
          SizedBox(
            height: 30.w,
            child: Text(botText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                )),
          ),
          SizedBox(
            height: 10.w,
          ),
          SizedBox(
            height: 150.w,
            width: 150.w,
            child: Lottie.asset("lib/assets/lottie_loading_3d_spheres.json"),
          ),
        ],
      ),
    );
  }
}

class BotInfo extends StatelessWidget {
  final String botText;
  const BotInfo({super.key, required this.botText});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Column(
        children: [
          Center(
              child: Text(botText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                  textAlign: TextAlign.center)),
          SizedBox(height: 100.w),
        ],
      ),
    );
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
