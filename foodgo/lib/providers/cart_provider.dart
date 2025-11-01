import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final List<CartItemModel> _items = [];
  final Map<String, String> _cartItemIds = {}; // Lưu mapping giữa cart item và document ID

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.item.price * item.quantity));

  Future<void> loadCartItems(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: userId)
          .get();

      _items.clear();
      _cartItemIds.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final cartItem = CartItemModel.fromJson(data);
        _items.add(cartItem);
        
        // Tạo key duy nhất cho cart item
        final key = _getCartItemKey(cartItem);
        _cartItemIds[key] = doc.id;
      }

    } catch (e) {
      _errorMessage = 'Lỗi khi tải giỏ hàng: $e';
      debugPrint('Error loading cart items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức đơn giản cho việc thêm từ MenuItemCard
  Future<void> addItem(MenuItemModel item, {String? userId}) async {
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
        // Thêm item mới vào Firestore
        final docRef = await _firestore.collection('cart_items').add({
          ...cartItem.toJson(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _items.add(cartItem);
        _cartItemIds[key] = docRef.id;
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
        await _firestore.collection('cart_items').doc(docId).update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Cập nhật local state
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
        await _firestore.collection('cart_items').doc(docId).delete();
        _cartItemIds.remove(key);
      }

      _items.removeWhere((item) => _getCartItemKey(item) == key);

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

      // Xóa tất cả cart items của user
      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      _cartItemIds.clear();

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
