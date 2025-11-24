import 'chat_cart_action.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isBot;
  final DateTime timestamp;
  final bool isTyping;
  final ChatCartAction? cartAction;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isBot,
    required this.timestamp,
    this.isTyping = false,
    this.cartAction,
  });

  factory ChatMessage.user(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isBot: false,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.bot(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isBot: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.typing() {
    return ChatMessage(
      id: 'typing',
      message: '...',
      isBot: true,
      timestamp: DateTime.now(),
      isTyping: true,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse cart action if present
    ChatCartAction? cartAction;
    String message = '';
    
    // Check if response has 'custom' field (Rasa format)
    if (json.containsKey('custom') && json['custom'] != null) {
      final customData = json['custom'] as Map<String, dynamic>;
      message = customData['message'] ?? customData['text'] ?? '';
      
      if (customData.containsKey('type') && customData['type'] != null) {
        cartAction = ChatCartAction.fromJson(customData);
      }
    } else {
      // Fallback to direct format
      message = json['text'] ?? json['message'] ?? '';
      
      if (json.containsKey('type') && json['type'] != null) {
        cartAction = ChatCartAction.fromJson(json);
      }
    }

    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isBot: true,
      timestamp: DateTime.now(),
      cartAction: cartAction,
    );
  }

  // Firestore serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isBot': isBot,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isTyping': isTyping,
      // We might want to serialize cartAction too if needed, but for now basic message is enough
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      isBot: map['isBot'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isTyping: map['isTyping'] ?? false,
    );
  }

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}