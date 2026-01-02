import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel item;
  final int quantity;
  final List<Map<String, dynamic>> selectedToppings;
  final String note;

  CartItemModel({
    required this.item,
    this.quantity = 1,
    this.selectedToppings = const [],
    this.note = '',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    int parseQuantity(dynamic value) {
      if (value == null) return 1;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 1;
      return 1;
    }

    // Try to get item data from 'item' key, or use json itself if 'item' is missing (flattened structure)
    final itemData = json['item'] is Map<String, dynamic> 
        ? json['item'] as Map<String, dynamic>
        : json;

    return CartItemModel(
      item: MenuItemModel.fromJson(itemData),
      quantity: parseQuantity(json['quantity']),
      selectedToppings:
          List<Map<String, dynamic>>.from(json['selectedToppings'] ?? const []),
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    'selectedToppings': selectedToppings,
    'note': note,
  };

  double get totalPrice =>
      (item.price + selectedToppings.fold(0.0, (sum, e) {
            final p = e['price'];
            if (p == null) return sum;
            if (p is num) return sum + p.toDouble();
            if (p is String) return sum + (double.tryParse(p) ?? 0.0);
            return sum;
          })) *
          quantity;
}

