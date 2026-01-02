import 'package:flutter/material.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/screen_service.dart' as screen;
import 'chat_message_bubble.dart';
import 'chat_quick_replies.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Function(String) onQuickReply;
  final Function(String, String, double, int)? onAddToCart;
  final VoidCallback? onGoToCart;
  final Function(String)? onDelete;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.onQuickReply,
    this.onAddToCart,
    this.onGoToCart,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Don't show quick replies at the beginning
          return SizedBox.shrink();
        }
        
        final message = messages[index];
        return GestureDetector(
          onLongPress: () {
            if (onDelete != null) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa tin nhắn?'),
                  content: const Text('Bạn có chắc muốn xóa tin nhắn này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete!(message.id);
                      },
                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          },
          child: ChatMessageBubble(
            message: message,
            onAddToCart: onAddToCart,
            onGoToCart: onGoToCart,
            onQuickReply: onQuickReply,
          ),
        );
      },
    );
  }
}
