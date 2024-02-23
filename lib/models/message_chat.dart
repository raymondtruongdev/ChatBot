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
/* Example code
 addMessage(
      message: ChatMessage(
        text: 'Who are you?',
        user: 'UserName',
        role: 'user',
        createdAt: DateTime.now(),
      ),
      isUserMessage: true,
    );
    addMessage(
      message: ChatMessage(
        text: 'I am bot',
        user: 'assistant',
        role: 'user',
        createdAt: DateTime.now(),
      ),
      isUserMessage: false,
    );
    */