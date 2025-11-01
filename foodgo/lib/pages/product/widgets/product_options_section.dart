import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProductOptionsSection extends StatelessWidget {
  final List<String> sizes;
  final List<dynamic> toppings; // Accept dynamic to handle both String and Map
  final String? selectedSize;
  final List<Map<String, dynamic>> selectedToppings;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<List<Map<String, dynamic>>> onToppingsChanged;

  const ProductOptionsSection({
    super.key,
    required this.sizes,
    required this.toppings,
    required this.selectedSize,
    required this.selectedToppings,
    required this.onSizeChanged,
    required this.onToppingsChanged,
  });

  String _getToppingName(dynamic topping) {
    if (topping is String) {
      return topping;
    } else if (topping is Map) {
      final toppingMap = Map<String, dynamic>.from(topping);
      return (toppingMap['name'] ??
              toppingMap['title'] ??
              topping.toString()).toString();
    }
    return topping.toString();
  }

  double _getToppingPrice(dynamic topping) {
    if (topping is Map) {
      final toppingMap = Map<String, dynamic>.from(topping);
      final priceValue = toppingMap['price'];
      if (priceValue is num) {
        return priceValue.toDouble();
      }
    }
    return 0.0; // Default price for string toppings
  }

  bool _isToppingSelected(String toppingName) {
    return selectedToppings.any((st) {
      final stName = st['name']?.toString() ?? '';
      return stName == toppingName;
    });
  }

  void _toggleTopping(String toppingName, double toppingPrice) {
    List<Map<String, dynamic>> newToppings = List.from(selectedToppings);

    if (_isToppingSelected(toppingName)) {
      newToppings.removeWhere((st) {
        return st['name']?.toString() == toppingName;
      });
    } else {
      newToppings.add({
        'name': toppingName,
        'price': toppingPrice,
      });
    }

    onToppingsChanged(newToppings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chọn size (nếu có)
        if (sizes.isNotEmpty) ...[
          const Text(
            'Chọn size:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: sizes.map((size) {
              bool isSelected = selectedSize == size;
              return FilterChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  onSizeChanged(selected ? size : null);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Chọn toppings (nếu có)
        if (toppings.isNotEmpty) ...[
          const Text(
            'Chọn toppings:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: toppings.map((topping) {
              final toppingName = _getToppingName(topping);
              final toppingPrice = _getToppingPrice(topping);
              final isSelected = _isToppingSelected(toppingName);

              return FilterChip(
                label: Text(toppingName),
                selected: isSelected,
                onSelected: (selected) {
                  _toggleTopping(toppingName, toppingPrice);
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}