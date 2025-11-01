import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/network_image_with_fallback.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, authProvider, cartProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Hình ảnh món ăn
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithFallback(
                      imageUrl: item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Thông tin món ăn
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${item.price.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            // Nút thêm vào giỏ hàng
                            GestureDetector(
                              onTap: () {
                                if (!authProvider.isLoggedIn) {
                                  // Chuyển đến trang đăng nhập thay vì CustomLoginForm
                                  Navigator.of(context).pushNamed(AppRoutes.login);
                                  return;
                                }
                                
                                cartProvider.addItem(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã thêm ${item.name} vào giỏ hàng'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


