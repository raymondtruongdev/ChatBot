import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/voice_to_text_controller.dart';
import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/message_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  TextEditingController textController = TextEditingController();

  bool _hasSpeech = false;
  final bool _logEvents = false;
  final bool _onDevice = false;
  late bool _isListening = false;
  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double level = 0.0;
  double _confidence = 1;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastVoiceDetectionStatus = 'done';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initSpeechState();
    onClick(RecordStatus.recording);
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
        stopListening();
        Navigator.pop(context);
        return;

      case RecordStatus.none:
        stopListening();
        await Future.delayed(const Duration(milliseconds: 500));
        return;

      case RecordStatus.recording:
        // stopListening();
        setState(() {
          textVoiceContent = '';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        onClick(RecordStatus.converting);
        return;

      case RecordStatus.send:
        // Return main Chat page
        String str = textController.text;
        sendMessage(str);
        stopListening();
        textVoiceContent = '';
        onClick(RecordStatus.exit);
        return;

      case RecordStatus.converting:
        startListening();
        // status = RecordStatus.recording;
        break;

      default:
    }

    setState(() {});
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';

    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    final options = SpeechListenOptions(
        onDevice: _onDevice,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      localeId: _currentLocaleId,
      // onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
    setState(() {
      _isListening = true;
    });
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
      _isListening = false;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    // _logEvent(
    //     'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');

    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
      textVoiceContent = result.recognizedWords;
      // CustomLogger().info('result.recognizedWords: ${result.recognizedWords}');
      // CustomLogger().info('result.finalResult: ${result.finalResult}');
      CustomLogger().info('lastWords: $lastWords');

      if (result.hasConfidenceRating && result.confidence > 0) {
        _confidence = result.confidence;
      }
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    CustomLogger().error(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastVoiceDetectionStatus = status;
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
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
                              color: Colors.green,
                              iconData: ((lastVoiceDetectionStatus == 'done') ||
                                      (_isListening == false))
                                  ? Icons.mic
                                  : Icons.stop,
                              onPressed: () {
                                if (_isListening == true) {
                                  if (lastVoiceDetectionStatus == 'done') {
                                    onClick(RecordStatus.recording);
                                  } else {
                                    onClick(RecordStatus.none);
                                  }
                                } else {
                                  onClick(RecordStatus.recording);
                                }
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
