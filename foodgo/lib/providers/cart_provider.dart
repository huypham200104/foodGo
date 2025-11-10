import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartService _cartService = CartService();
  StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>? _subscription;
  
  final List<CartItemModel> _items = [];
  final Map<String, String> _cartItemIds = {}; // Lưu mapping giữa cart item và document ID

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.item.price * item.quantity));

  Future<void> subscribe(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _subscription?.cancel();
      _subscription = _cartService.streamCartDocs(userId).listen((docs) {
        _items.clear();
        _cartItemIds.clear();
        for (final doc in docs) {
          final data = doc.data();
          final cartItem = CartItemModel.fromJson(data);
          _items.add(cartItem);
          final key = _getCartItemKey(cartItem);
          _cartItemIds[key] = doc.id;
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = 'Lỗi stream giỏ hàng: $e';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Lỗi khi đăng ký giỏ hàng: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unsubscribe() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  // Phương thức đơn giản cho việc thêm từ MenuItemCard
  Future<void> addItem(MenuItemModel item, int i, {String? userId}) async {
    await addToCart(
      userId: userId ?? 'temp_user', // Temporary user ID nếu chưa đăng nhập
      item: item,
      quantity: 1,
    );
  }

  Future<void> addToCart({
    required String userId,
    required MenuItemModel item,
    int quantity = 1,
    List<Map<String, dynamic>> selectedToppings = const [],
    String note = '',
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Tạo cart item mới
      final cartItem = CartItemModel(
        item: item,
        quantity: quantity,
        selectedToppings: selectedToppings,
        note: note,
      );

      final key = _getCartItemKey(cartItem);

      // Kiểm tra xem item đã tồn tại chưa
      final existingIndex = _items.indexWhere((existingItem) =>
          _getCartItemKey(existingItem) == key);

      if (existingIndex != -1) {
        // Cập nhật số lượng item có sẵn
        final existingItem = _items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        await updateQuantity(existingItem, newQuantity);
      } else {
        // Thêm item mới qua service (stream sẽ tự đồng bộ lại _items)
        await _cartService.addItem(userId: userId, cartItem: cartItem);
      }

    } catch (e) {
      _errorMessage = 'Lỗi khi thêm vào giỏ hàng: $e';
      debugPrint('Error adding to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(CartItemModel cartItem, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItem);
        return;
      }

      final key = _getCartItemKey(cartItem);
      final docId = _cartItemIds[key];
      if (docId != null) {
        await _cartService.updateQuantity(docId: docId, quantity: newQuantity);

        // Optimistically update local state for immediate UI feedback
        final index = _items.indexWhere((item) => _getCartItemKey(item) == key);
        if (index != -1) {
          _items[index] = CartItemModel(
            item: cartItem.item,
            quantity: newQuantity,
            selectedToppings: cartItem.selectedToppings,
            note: cartItem.note,
          );
        }
      }

    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật số lượng: $e';
      debugPrint('Error updating quantity: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeFromCart(CartItemModel cartItem) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final key = _getCartItemKey(cartItem);
      final docId = _cartItemIds[key];
      if (docId != null) {
        await _cartService.removeItem(docId: docId);
      }

    } catch (e) {
      _errorMessage = 'Lỗi khi xóa khỏi giỏ hàng: $e';
      debugPrint('Error removing from cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _cartService.clearCart(userId: userId);

    } catch (e) {
      _errorMessage = 'Lỗi khi xóa giỏ hàng: $e';
      debugPrint('Error clearing cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo key duy nhất cho cart item để tracking
  String _getCartItemKey(CartItemModel cartItem) {
    final toppingsString = cartItem.selectedToppings
        .map((t) => '${t['name']}_${t['price']}')
        .join(',');
    return '${cartItem.item.id}_${cartItem.note}_$toppingsString';
  }

  bool _areToppingsEqual(List<Map<String, dynamic>> toppings1, List<Map<String, dynamic>> toppings2) {
    if (toppings1.length != toppings2.length) return false;
    
    for (int i = 0; i < toppings1.length; i++) {
      if (toppings1[i]['name'] != toppings2[i]['name'] || 
          toppings1[i]['price'] != toppings2[i]['price']) {
        return false;
      }
    }
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
