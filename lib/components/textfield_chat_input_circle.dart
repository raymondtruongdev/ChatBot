import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldChatInputCircle extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function()? onPressed;
  final Function onSubmitted;
  final Function onPressedVoiceChat;

  const TextFieldChatInputCircle({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    required this.onSubmitted,
    this.onPressed,
    required this.onPressedVoiceChat,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: 30.w),
        child: Container(
          width: 200.w,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            color: (Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.all(Radius.circular(30.w)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: TextField(
                    onSubmitted: (value) => onSubmitted(),
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: 1,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: (Theme.of(context).colorScheme.secondary),
                      hintText: 'Type a message',
                    ),
                  ),
                ),
              ),
              Container(
                width: 40.w,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                margin: EdgeInsets.only(right: 5.w),
                child: IconButton(
                  onPressed: () {
                    onPressedVoiceChat();
                  },
                  icon: const Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
              // SizedBox(
              //   width: 10.w,
              // ),
              // // Send Button for chat
              // Container(
              //   width: 40.w,
              //   decoration: const BoxDecoration(
              //       color: Colors.green, shape: BoxShape.circle),
              //   margin: EdgeInsets.only(right: 5.w),
              //   child: IconButton(
              //     onPressed: () {
              //       onPressed();
              //     },
              //     icon: const Icon(
              //       Icons.arrow_upward,
              //       color: Colors.white,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
