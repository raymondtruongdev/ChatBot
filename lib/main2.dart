import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/voice_to_text_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/themes/light_mode.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

final VoiceToTextController voiceBotController =
    Get.put(VoiceToTextController(), permanent: true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set immersive system UI mode for Android (full screen)
    //- However it will make 2 times init app
    // --> can not fix this issue now
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    CustomLogger logger = CustomLogger();
    logger.error('MyApp Screen build');

    return MaterialApp(
        debugShowCheckedModeBanner: false, // turn off debug banner
        theme: lighMode,
        home: SafeArea(
          child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: const Center(
                child: HomePage(),
              )),
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
    );
  }
}
