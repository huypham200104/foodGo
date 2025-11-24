
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/chat_service.dart';
import '../../models/chat_message_model.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'widgets/chat_header.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/chat_input_field.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen.ScreenService.init(context);
  }

  void _initializeChat() {
    // Get user ID from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.currentUser?.id ?? 'anonymous_user';
    
    // Check if we need to add welcome message (only if no messages exist)
    // This logic might need adjustment based on stream, but for now we rely on stream.
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    print('🚀 Chat: Sending message: "$message"');

    // Clear input
    _messageController.clear();
    
    // Create and save user message
    final userMessage = ChatMessage.user(message);
    await ChatService.saveMessage(userMessage, _userId!);
    
    setState(() {
      _isLoading = true;
    });
    
    _scrollToBottom();

    try {
      print('🔄 Chat: Calling ChatService.sendMessage...');
      
      // Send to backend
      final responses = await ChatService.sendMessage(
        userId: _userId!,
        message: message,
      );
      
      print('✅ Chat: Received ${responses.length} responses');
      
      // Save bot responses
      for (final response in responses) {
        await ChatService.saveMessage(response, _userId!);
        
        // Check for cart actions and auto-add to cart
        print('🔍 Checking response for cart action: ${response.cartAction?.type}');
        if (response.cartAction?.isOrderAction == true) {
          print('🛒 Found order action, attempting to add to cart...');
          _handleAutoAddToCart(response.cartAction!);
        }
      }
      
      if (responses.isEmpty) {
         // Fallback message if no response
          final fallback = ChatMessage.bot(
            'Xin lỗi, tôi không thể kết nối tới server ngay lúc này. Vui lòng thử lại sau! 😔'
          );
          await ChatService.saveMessage(fallback, _userId!);
      }

    } catch (e) {
      print('❌ Chat: Error occurred: $e');
      
      final errorMessage = ChatMessage.bot(
          'Xin lỗi, đã có lỗi xảy ra: ${e.toString()}. Vui lòng thử lại sau! 😔'
        );
      await ChatService.saveMessage(errorMessage, _userId!);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
      print('🏁 Chat: Message sending completed');
    }
  }

  void _deleteMessage(String messageId) async {
    await ChatService.deleteMessage(messageId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa tin nhắn')),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ đoạn chat?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatService.clearChat(_userId!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa toàn bộ đoạn chat')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _sendQuickReply(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAutoAddToCart(dynamic cartAction) {
    try {
      print('🔧 _handleAutoAddToCart called with: ${cartAction.toString()}');
      print('🔧 Item ID: ${cartAction.itemId}');
      print('🔧 Item Name: ${cartAction.itemName}');
      print('🔧 Unit Price: ${cartAction.unitPrice}');
      print('🔧 Quantity: ${cartAction.quantity}');
      print('🔧 Current userId: $_userId');
      
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Create menu item from chat response
      final menuItem = MenuItemModel(
        id: cartAction.itemId ?? '',
        name: cartAction.itemName ?? '',
        description: cartAction.description ?? 'Đặt từ chat',
        price: cartAction.unitPrice?.toDouble() ?? 0.0,
        imageUrl: cartAction.imageUrl ?? '',
        category: 'Chat Order',
        isAvailable: true,
        restaurantId: 'chat',
        ingredients: ['Đặt từ chatbot'],
      );

      print('🔧 Created MenuItemModel: ${menuItem.name} - ${menuItem.price}');

      // Add to cart with explicit userId
      cartProvider.addToCart(
        userId: _userId ?? 'anonymous_user',
        item: menuItem,
        quantity: cartAction.quantity ?? 1,
      );
      
      print('🛒 Auto-added to cart: ${cartAction.quantity}x ${cartAction.itemName}');
      print('🛒 Current cart item count: ${cartProvider.itemCount}');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã thêm ${cartAction.quantity}x ${cartAction.itemName} vào giỏ hàng'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error auto-adding to cart: $e');
      print('❌ Error details: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi thêm món vào giỏ hàng: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleManualAddToCart(String itemId, String itemName, double unitPrice, int quantity) {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      final menuItem = MenuItemModel(
        id: itemId,
        name: itemName,
        description: 'Đặt từ chat',
        price: unitPrice,
        imageUrl: '',
        category: 'Chat Order',
        isAvailable: true,
        restaurantId: 'chat',
        ingredients: ['Đặt từ chatbot'],
      );

      cartProvider.addItem(menuItem, quantity);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã thêm thêm ${quantity}x ${itemName} vào giỏ hàng'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error manually adding to cart: $e');
    }
  }

  void _goToCart() {
    Navigator.of(context).pop(); // Close chat
    Navigator.pushNamed(context, AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screen.ScreenService.mediumSpacing),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: screen.ScreenService.smallSpacing),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            ChatHeader(
              onClose: () => Navigator.of(context).pop(),
              onClearChat: _clearChat,
            ),
            
            // Messages area
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: ChatService.getMessagesStream(_userId ?? 'anonymous_user'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  
                  if (messages.isEmpty) {
                     // Show welcome message if empty
                     // Note: We don't save welcome message to DB to avoid clutter, 
                     // or we could save it once. For now, just show it.
                     return ChatMessageList(
                        messages: [ChatService.getWelcomeMessage()],
                        scrollController: _scrollController,
                        onQuickReply: _sendQuickReply,
                        onAddToCart: _handleManualAddToCart,
                        onGoToCart: _goToCart,
                        onDelete: null, // Cannot delete welcome message
                      );
                  }

                  return ChatMessageList(
                    messages: messages,
                    scrollController: _scrollController,
                    onQuickReply: _sendQuickReply,
                    onAddToCart: _handleManualAddToCart,
                    onGoToCart: _goToCart,
                    onDelete: _deleteMessage,
                  );
                },
              ),
            ),
            
            // Input area
            ChatInputField(
              controller: _messageController,
              isLoading: _isLoading,
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}