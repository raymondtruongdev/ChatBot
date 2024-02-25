import 'package:flutter/material.dart';

class TextFieldChatInput extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function onPressed;
  const TextFieldChatInput({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.onPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          color: (Theme.of(context).colorScheme.secondary),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 5,
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
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              margin: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  onPressed();
                },
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
