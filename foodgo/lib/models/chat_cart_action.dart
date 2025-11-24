class ChatCartAction {
  final String type;
  final String? itemId;
  final String? itemName;
  final double? unitPrice;
  final int? quantity;
  final double? totalPrice;
  final String message;
  final List<String>? quickReplies;
  final String? imageUrl;
  final String? description;

  ChatCartAction({
    required this.type,
    this.itemId,
    this.itemName,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    required this.message,
    this.quickReplies,
    this.imageUrl,
    this.description,
  });

  factory ChatCartAction.fromJson(Map<String, dynamic> json) {
    print('🔍 ChatCartAction.fromJson input: $json');
    
    final item = json['item'] as Map<String, dynamic>?;
    final quickRepliesList = json['quick_replies'] as List<dynamic>?;
    
    final action = ChatCartAction(
      type: json['type'] ?? '',
      itemId: item?['id'],
      itemName: item?['name'],
      unitPrice: (item?['price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      message: json['message'] ?? '',
      quickReplies: quickRepliesList?.map((e) => e.toString()).toList(),
      imageUrl: item?['imageUrl'],
      description: item?['description'],
    );
    
    print('🔍 Created ChatCartAction: type=${action.type}, itemId=${action.itemId}, itemName=${action.itemName}');
    print('🔍 Is order action: ${action.isOrderAction}');
    
    return action;
  }

  bool get isOrderAction => type == 'order' && itemId != null;
  bool get isAskMoreAction => type == 'ask_more';
  bool get hasValidItem => itemId != null && itemName != null && unitPrice != null && quantity != null;
}