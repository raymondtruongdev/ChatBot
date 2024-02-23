import 'package:chat_bot/pages/chat_page.dart';
import 'package:chat_bot/themes/light_mode.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
