import 'chat_cart_action.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Món ăn',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final bool isBot;
  final DateTime timestamp;
  final bool isTyping;
  final ChatCartAction? cartAction;
  final List<MenuItem>? menuItems;
  final bool hasMoreMenu;
  final int totalMenuItems;
  final List<String>? quickReplies;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isBot,
    required this.timestamp,
    this.isTyping = false,
    this.cartAction,
    this.menuItems,
    this.hasMoreMenu = false,
    this.totalMenuItems = 0,
    this.quickReplies,
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
    List<MenuItem>? menuItems;
    bool hasMoreMenu = false;
    int totalMenuItems = 0;
    List<String>? quickReplies;
    
    // Check if response has 'custom' field (Rasa format)
    if (json.containsKey('custom') && json['custom'] != null) {
      final customData = json['custom'] as Map<String, dynamic>;
      message = customData['message'] ?? customData['text'] ?? '';
      
      // Parse menu items if type is 'menu', 'new_items', 'recommendation', 'price_range_items'
      final type = customData['type'];
      if ((type == 'menu' || type == 'new_items' || type == 'recommendation' || type == 'price_range_items') 
          && customData.containsKey('items')) {
        final items = customData['items'] as List<dynamic>?;
        if (items != null) {
          menuItems = items.map((item) => MenuItem.fromJson(item)).toList();
        }
        hasMoreMenu = customData['has_more'] ?? false;
        totalMenuItems = customData['total_items'] ?? 0;
      }
      
      // Parse quick_replies if present
      if (customData.containsKey('quick_replies')) {
        final replies = customData['quick_replies'] as List<dynamic>?;
        if (replies != null) {
          quickReplies = replies.map((r) => r.toString()).toList();
        }
      }
      
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
      menuItems: menuItems,
      hasMoreMenu: hasMoreMenu,
      totalMenuItems: totalMenuItems,
      quickReplies: quickReplies,
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
