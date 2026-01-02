import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class FloatingChatButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool showOnlineIndicator;
  final EdgeInsetsGeometry? initialMargin;

  const FloatingChatButton({
    super.key,
    this.onPressed,
    this.showOnlineIndicator = true,
    this.initialMargin,
  });

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  
  Offset _position = Offset.zero;
  bool _isDragging = false;
  late Size _screenSize;
  final double _buttonSize = 56.0;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation cho online indicator
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation khi thả button
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    
    // Set initial position (bottom right corner)
    if (_position == Offset.zero) {
      _position = Offset(
        _screenSize.width - _buttonSize - 20,
        _screenSize.height - _buttonSize - 120, // Avoid bottom nav
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _bounceController.reverse();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(0, _screenSize.width - _buttonSize),
        (_position.dy + details.delta.dy).clamp(0, _screenSize.height - _buttonSize - 100),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    // Snap to edges for better UX
    _snapToEdge();
    
    _bounceController.forward();
  }

  void _snapToEdge() {
    const double snapThreshold = 50;
    double newX = _position.dx;
    
    // Snap to left or right edge
    if (_position.dx < _screenSize.width / 2) {
      // Snap to left
      if (_position.dx < snapThreshold) {
        newX = 20;
      }
    } else {
      // Snap to right
      if (_position.dx > _screenSize.width - _buttonSize - snapThreshold) {
        newX = _screenSize.width - _buttonSize - 20;
      }
    }
    
    setState(() {
      _position = Offset(newX, _position.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () {
          if (!_isDragging) {
            _handleChatTap();
          }
        },
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isDragging ? 1.1 : _bounceAnimation.value,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark ?? AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isDragging ? 0.6 : 0.4),
                      blurRadius: _isDragging ? 16 : 12,
                      offset: Offset(0, _isDragging ? 6 : 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Chat icon
                    Center(
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: ScreenService.isSmallScreen ? 24 : 28,
                      ),
                    ),
                    
                    // Online indicator với pulse effect
                    if (widget.showOnlineIndicator)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                    // Unread messages indicator (có thể thêm sau)
                    // if (hasUnreadMessages)
                    //   Positioned(
                    //     right: 4,
                    //     top: 4,
                    //     child: _buildUnreadBadge(unreadCount),
                    //   ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleChatTap() {
    // Haptic feedback
    // HapticFeedback.lightImpact();
    
    // Add some visual feedback
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    // Call custom onPressed or default navigation
    if (widget.onPressed != null) {
      widget.onPressed!(); // Sửa lỗi ở đây
    } else {
      _navigateToChat();
    }
  }

  void _navigateToChat() {
    // Navigate to chat screen (sẽ implement sau)
    // Navigator.pushNamed(context, '/chat'); // hoặc AppRoutes.chat
    
    // Temporary: Show coming soon dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Chat Bot',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Chức năng chat với bot AI đang được phát triển.\nSẽ sớm ra mắt trong phiên bản tiếp theo!',
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cảm ơn bạn đã quan tâm! 🤖'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tôi hiểu'),
          ),
        ],
      ),
    );
  }

  // Widget để hiển thị badge tin nhắn chưa đọc (dùng sau)
  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.warning],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

