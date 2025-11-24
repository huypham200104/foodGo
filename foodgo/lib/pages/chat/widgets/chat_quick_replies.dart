import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../services/chat_service.dart';

class ChatQuickReplies extends StatelessWidget {
  final Function(String) onQuickReply;
  final bool showReplies;

  const ChatQuickReplies({
    super.key,
    required this.onQuickReply,
    required this.showReplies,
  });

  @override
  Widget build(BuildContext context) {
    if (!showReplies) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: screen.ScreenService.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý nhanh:',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          Wrap(
            spacing: screen.ScreenService.smallSpacing,
            runSpacing: screen.ScreenService.smallSpacing / 2,
            children: ChatService.getQuickReplies().map((reply) {
              return _buildQuickReplyChip(reply);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String reply) {
    return GestureDetector(
      onTap: () => onQuickReply(reply),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screen.ScreenService.mediumSpacing,
          vertical: screen.ScreenService.smallSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(20),
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
    );
  }
}
