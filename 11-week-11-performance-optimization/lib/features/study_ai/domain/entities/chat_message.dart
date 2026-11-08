enum MessageRole { user, model }

enum MessageStatus { sending, success, error }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.success,
    this.errorMessage,
  });

  final String id;
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final String? errorMessage;

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    String? errorMessage,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
