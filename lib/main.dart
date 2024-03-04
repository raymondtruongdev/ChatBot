import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/pages/circle_chat_page.dart';
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
    CustomLogger logger = CustomLogger();
    // Get Size of device
    double widthScreenDevice = MediaQuery.of(context).size.width;
    double heightScreenDevice = MediaQuery.of(context).size.height;
    if ((widthScreenDevice > 0) && (heightScreenDevice > 0)) {
      logger.debug(
          'HomePage: Width: $widthScreenDevice, Height: $heightScreenDevice');
      chatBotController.updateWatchSize(widthScreenDevice, heightScreenDevice);
    } else {
      logger.error(
          'HomePage: Width: $widthScreenDevice, Height: $heightScreenDevice');
    }
    if ((widthScreenDevice > 0) && (heightScreenDevice > 0)) {
      return const CircleChatPage();
    } else {
      return const Center(child: Text('Loading......'));
    }
  }
}

class CircleWiget extends StatefulWidget {
  const CircleWiget({super.key});

  @override
  State<CircleWiget> createState() => _CircleWigetState();
}

class _CircleWigetState extends State<CircleWiget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text('helo how are you  to day ?'),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text('helo how are you  to day ?'),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text('helo how are you  to day ?'),
          ),
        ],
      ),
    );
  }
}
