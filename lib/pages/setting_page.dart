import 'package:chat_bot/controller/chatbot_controller.dart';
import 'package:chat_bot/controller/speech_to_text_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

final ChatBotController chatBotController =
    Get.put(ChatBotController(), permanent: true);

final SpeechToTextController speechToTextController =
    Get.put(SpeechToTextController(), permanent: true);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double watchSize = chatBotController.getWatchSize();
    TextEditingController textController = TextEditingController();
    textController.text = chatBotController.getIpBot();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color:
              chatBotController.isCircleDevice() ? Colors.black : Colors.white,
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
                      const HeaderPage(),
                      SizedBox(height: 20.w),
                      Padding(
                        padding: EdgeInsets.only(left: 50.0.w),
                        child: Row(
                          children: [
                            Text('Language: ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.sp)),
                            SizedBox(width: 30.w),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors
                                    .black, // Set the background color here
                                borderRadius: BorderRadius.circular(
                                    5.0), // Optional: Add border radius for styling
                              ),
                              child: DropdownButton<String>(
                                onChanged: (selectedVal) {
                                  print(selectedVal);
                                  setState(() {
                                    speechToTextController.currentLocaleIdBot =
                                        selectedVal ?? 'default';
                                  });
                                },
                                value:
                                    speechToTextController.currentLocaleIdBot,
                                dropdownColor:
                                    const Color.fromARGB(220, 90, 90, 90),
                                items: speechToTextController.languageNames
                                    .map((localeName) {
                                  return DropdownMenuItem<String>(
                                    value: localeName.localeId,
                                    child: Text(
                                      localeName.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.sp),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0.w),
                        child: Row(
                          children: [
                            Text('IP AIBOT: ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.sp)),
                            SizedBox(width: 10.w),
                            Container(
                              // height: 100.w,
                              width: 200.w,
                              decoration: BoxDecoration(
                                // Set the background color here
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: textController,
                                minLines: 1,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.blueGrey,
                                ),
                                onChanged: (text) {
                                  // Set new Bot IP
                                  chatBotController
                                      .setIpBot(textController.text);
                                },
                              ),
                            )
                          ],
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
    );
  }
}

class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.w,
      color: const Color(0xff145503),
      child: Padding(
        padding: EdgeInsets.only(top: 10.w),
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
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 2.0.w, // Border width
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Go to MainPage
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(
                            0), // Remove button elevation
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        // Set background color to transparent
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Text(
                  'Setting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp, // Using ScreenUtil for font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
