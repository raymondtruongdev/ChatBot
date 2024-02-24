/* Example code
ChatMessage(
          text: 'who are you',
          user: 'username',
          createdAt: DateTime.now(),
          role: Role.user,
        ),
 */
class ChatMessage {
  late String text;
  late String user;
  late String role;
  final DateTime createdAt;

  ChatMessage({
    this.text = '',
    this.user = '',
    this.role = 'user',
    required this.createdAt,
  });
}

class Role {
  static const String user = 'user';
  static const String assistant = 'assistant';
}
