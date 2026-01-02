import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSendMessage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: screen.ScreenService.mediumText,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screen.ScreenService.mediumSpacing,
                    vertical: screen.ScreenService.smallSpacing,
                  ),
                ),
                style: TextStyle(
                  fontSize: screen.ScreenService.mediumText,
                  color: AppColors.textPrimary,
                ),
                maxLines: null,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                // Fix cho Vietnamese input method
                enableIMEPersonalizedLearning: false,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.none,
                // Thêm callback gửi tin nhắn
                onSubmitted: (value) {
                  if (!widget.isLoading && value.trim().isNotEmpty) {
                    widget.onSendMessage();
                  }
                },
                // Thay đổi cách handle submit
                onEditingComplete: () {
                  // Không làm gì để tránh conflict với Vietnamese IME
                },
                enabled: !widget.isLoading,
              ),
            ),
          ),
          SizedBox(width: screen.ScreenService.smallSpacing),
          Container(
            decoration: BoxDecoration(
              gradient: widget.isLoading 
                  ? null 
                  : AppColors.primaryGradient,
              color: widget.isLoading 
                  ? AppColors.textLight 
                  : null,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isLoading ? null : widget.onSendMessage,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
