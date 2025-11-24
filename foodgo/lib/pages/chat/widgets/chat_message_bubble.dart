import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/chat_message_model.dart';
import 'chat_typing_indicator.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String, String, double, int)? onAddToCart;
  final VoidCallback? onGoToCart;
  final Function(String)? onQuickReply;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onAddToCart,
    this.onGoToCart,
    this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    
    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.smallSpacing),
      child: Row(
        mainAxisAlignment: isBot 
            ? MainAxisAlignment.start 
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            _buildBotAvatar(),
            SizedBox(width: screen.ScreenService.smallSpacing),
          ],
          
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screen.ScreenService.mediumSpacing,
                vertical: screen.ScreenService.smallSpacing,
              ),
              decoration: BoxDecoration(
                gradient: isBot ? null : AppColors.primaryGradient,
                color: isBot ? AppColors.background : null,
                borderRadius: BorderRadius.circular(16),
                border: isBot ? Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isTyping)
                    ChatTypingIndicator()
                  else
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isBot 
                            ? AppColors.textPrimary 
                            : Colors.white,
                        fontSize: screen.ScreenService.mediumText,
                        height: 1.4,
                      ),
                    ),
                  
                  // Cart action buttons
                  if (message.cartAction?.isOrderAction == true && isBot) ...[
                    SizedBox(height: screen.ScreenService.smallSpacing),
                    _buildCartActions(),
                  ],
                  
                  // Quick replies for ask_more type
                  if (message.cartAction?.isAskMoreAction == true && isBot) ...[
                    SizedBox(height: screen.ScreenService.smallSpacing),
                    _buildQuickReplies(),
                  ],
                  
                  if (!message.isTyping) ...[
                    SizedBox(height: 4),
                    Text(
                      message.formattedTime,
                      style: TextStyle(
                        color: isBot 
                            ? AppColors.textSecondary 
                            : Colors.white70,
                        fontSize: screen.ScreenService.smallText - 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (!isBot) ...[
            SizedBox(width: screen.ScreenService.smallSpacing),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        message.isTyping ? Icons.more_horiz : Icons.smart_toy,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildCartActions() {
    final cartAction = message.cartAction!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order summary card
        Container(
          padding: EdgeInsets.all(screen.ScreenService.smallSpacing),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: screen.ScreenService.smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã thêm vào giỏ hàng',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: screen.ScreenService.smallText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${cartAction.quantity}x ${cartAction.itemName}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: screen.ScreenService.mediumText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(cartAction.totalPrice ?? 0).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: screen.ScreenService.mediumText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: screen.ScreenService.smallSpacing),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (onAddToCart != null && cartAction.hasValidItem) {
                    onAddToCart!(
                      cartAction.itemId!,
                      cartAction.itemName!,
                      cartAction.unitPrice!,
                      cartAction.quantity!,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(
                    vertical: screen.ScreenService.smallSpacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Thêm tiếp',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: screen.ScreenService.smallText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: screen.ScreenService.smallSpacing),
            
            Expanded(
              child: ElevatedButton(
                onPressed: onGoToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: screen.ScreenService.smallSpacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screen.ScreenService.smallText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = message.cartAction?.quickReplies ?? [];
    
    if (quickReplies.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gợi ý:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: screen.ScreenService.smallText,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screen.ScreenService.smallSpacing / 2),
        Wrap(
          spacing: screen.ScreenService.smallSpacing,
          runSpacing: screen.ScreenService.smallSpacing / 2,
          children: quickReplies.map((reply) => 
            InkWell(
              onTap: () => onQuickReply?.call(reply),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.ScreenService.smallSpacing,
                  vertical: screen.ScreenService.smallSpacing / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  reply,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: screen.ScreenService.smallText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }
}