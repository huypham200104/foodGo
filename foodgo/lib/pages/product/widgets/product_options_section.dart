import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

/// A simplified toppings-only selector.
///
/// Keeps the same constructor signature for compatibility but only
/// renders the toppings section (no size selection).
class ProductOptionsSection extends StatelessWidget {
  final List<String> sizes;
  final List<dynamic> toppings;
  final String? selectedSize;
  final List<Map<String, dynamic>> selectedToppings;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<List<Map<String, dynamic>>> onToppingsChanged;

  const ProductOptionsSection({
    super.key,
    this.sizes = const [],
    this.toppings = const [],
    this.selectedSize,
    this.selectedToppings = const [],
    required this.onSizeChanged,
    required this.onToppingsChanged,
  });

  String _getToppingName(dynamic topping) {
    if (topping is String) return topping;
    if (topping is Map) {
      final m = Map<String, dynamic>.from(topping);
      return (m['name'] ?? m['title'] ?? m.toString()).toString();
    }
    return topping.toString();
  }

  double _getToppingPrice(dynamic topping) {
    if (topping is Map) {
      final m = Map<String, dynamic>.from(topping);
      final p = m['price'];
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p) ?? 0.0;
    }
    return 0.0;
  }

  bool _isToppingSelected(String name) {
    return selectedToppings.any((st) => (st['name']?.toString() ?? '') == name);
  }

  void _toggleTopping(String name, double price) {
    // Single-selection behavior: select this topping only, or clear if already selected
    final currentlySelected = _isToppingSelected(name);
    if (currentlySelected) {
      onToppingsChanged(<Map<String, dynamic>>[]);
    } else {
      onToppingsChanged(<Map<String, dynamic>>[{'name': name, 'price': price}]);
    }
  }

  String _formatPrice(double price) {
    if (price == 0) return '';
    return _formatVND(price.toInt());
  }

  String _formatVND(int value) {
    final s = value.toString();
    // fallback: manual grouping
    if (s.length <= 3) return '$s VND';
    final buffer = StringBuffer();
    int rem = s.length % 3;
    if (rem == 0) rem = 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()} VND';
  }

  @override
  Widget build(BuildContext context) {
    if (toppings.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(ScreenService.smallSpacing / 2),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(ScreenService.smallSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, 
                size: ScreenService.isSmallScreen ? 18 : 20),
              SizedBox(width: ScreenService.smallSpacing / 2),
              Text(
                'Thêm topping',
                style: TextStyle(
                  fontSize: ScreenService.mediumText, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (selectedToppings.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenService.smallSpacing / 2,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${selectedToppings.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenService.smallText,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ScreenService.smallSpacing / 2),
          Wrap(
            spacing: ScreenService.smallSpacing / 2,
            runSpacing: ScreenService.smallSpacing / 2,
            children: toppings.map((t) {
              var name = _getToppingName(t);
              // If name looks like a map string (e.g. "{price: 10000, name: Size M}"),
              // try to extract the name value after 'name:' for nicer display.
              if (name.startsWith('{') && name.contains('name:')) {
                final m = RegExp(r'name:\s*([^,}\n]+)').firstMatch(name);
                if (m != null) {
                  name = m.group(1)!.trim();
                }
              }
              final price = _getToppingPrice(t);
              final selected = _isToppingSelected(name);
              final priceText = _formatPrice(price);

              return GestureDetector(
                onTap: () => _toggleTopping(name, price),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenService.smallSpacing, 
                    vertical: ScreenService.smallSpacing / 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                    border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Icon(Icons.check_circle, 
                          size: ScreenService.isSmallScreen ? 14 : 16, 
                          color: Colors.white,
                        ),
                        SizedBox(width: ScreenService.smallSpacing / 3),
                      ],
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: ScreenService.smallText,
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      if (priceText.isNotEmpty) ...[
                        SizedBox(width: ScreenService.smallSpacing / 3),
                        Text(
                          priceText,
                          style: TextStyle(
                            color: selected ? Colors.white70 : AppColors.textSecondary,
                            fontSize: ScreenService.smallText - 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
