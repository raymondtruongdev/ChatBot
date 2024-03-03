import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/voice_to_text_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/themes/light_mode.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
                child: SpeechScreen(),
              )),
        ));
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  late bool _isListening = false;
  late String _text = 'Press the button and start speaking';
  late double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(
                  'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.green,
        duration: const Duration(milliseconds: 2000),
        startDelay: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _isListen,
          backgroundColor: Colors.blue,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _isListen() async {
    _text = '';
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          CustomLogger().debug('onStatus: $val');
          if (val == 'done') {
            _speech.stop();
            setState(() => _isListening = false);
            _speech.stop();
            CustomLogger().debug('Speech stopped');
          }
        },
        onError: (val) => CustomLogger().error('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            CustomLogger().info(_text);
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
}
