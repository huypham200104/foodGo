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

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    item: MenuItemModel.fromJson(json['item']),
    quantity: json['quantity'] ?? 1,
    selectedToppings:
    List<Map<String, dynamic>>.from(json['selectedToppings'] ?? const []),
    note: json['note'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    'selectedToppings': selectedToppings,
    'note': note,
  };

  double get totalPrice =>
      (item.price +
          selectedToppings.fold(0, (sum, e) => sum + (e['price'] ?? 0))) *
          quantity;
}
