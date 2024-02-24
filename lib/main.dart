import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/pages/chat_page.dart';
import 'package:chat_bot/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set immersive system UI mode for Android (full screen)
    //- However it will make 2 times init app
    // --> can not fix this issue now
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    CustomLogger logger = CustomLogger();
    // Get Size of device
    double widthScreenDevice = MediaQuery.of(context).size.width;
    double heightScreenDevice = MediaQuery.of(context).size.height;
    if ((widthScreenDevice > 0) && (heightScreenDevice > 0)) {
      logger.info('Width: $widthScreenDevice, Height: $heightScreenDevice');
    } else {
      logger.error('Screen size is 0');
    }

    if (widthScreenDevice == 0 || heightScreenDevice == 0) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: Text("Loading..."))),
        debugShowCheckedModeBanner: false,
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false, // turn off debug banner
        theme: lighMode,
        home: SafeArea(
          child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: const Center(
                child: ChatPage(),
              )),
        ),
      );
    }
  }
}
