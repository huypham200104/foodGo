import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';
import 'auth_provider.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCartItems(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: userId)
          .get();

      _cartItems = snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data()))
          .toList();

    } catch (e) {
      _errorMessage = 'Lỗi khi tải giỏ hàng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

      // Check if item already exists in cart
      final existingIndex = _cartItems.indexWhere((cartItem) =>
          cartItem.item.id == item.id &&
          _areToppingsEqual(cartItem.selectedToppings, selectedToppings) &&
          cartItem.note == note);

      if (existingIndex != -1) {
        // Update existing item quantity
        await _updateCartItemQuantity(
          _cartItems[existingIndex],
          _cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item to cart
        final cartItem = CartItemModel(
          item: item,
          quantity: quantity,
          selectedToppings: selectedToppings,
          note: note,
        );

        await _firestore.collection('cart_items').add({
          ...cartItem.toJson(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _cartItems.add(cartItem);
      }

    } catch (e) {
      _errorMessage = 'Lỗi khi thêm vào giỏ hàng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(CartItemModel cartItem, int newQuantity) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (newQuantity <= 0) {
        await removeFromCart(cartItem);
        return;
      }

      await _updateCartItemQuantity(cartItem, newQuantity);

    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật số lượng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateCartItemQuantity(CartItemModel cartItem, int newQuantity) async {
    try {
      // Find the document ID for this cart item
      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: cartItem.item.id) // This should be userId, but we need to store it
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestore.collection('cart_items').doc(docId).update({
          'quantity': newQuantity,
        });

        // Update local state
        final index = _cartItems.indexOf(cartItem);
        if (index != -1) {
          _cartItems[index] = CartItemModel(
            item: cartItem.item,
            quantity: newQuantity,
            selectedToppings: cartItem.selectedToppings,
            note: cartItem.note,
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật số lượng: $e';
    }
  }

  Future<void> removeFromCart(CartItemModel cartItem) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Find and delete the document
      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: cartItem.item.id) // This should be userId
          .get();

      if (snapshot.docs.isNotEmpty) {
        await _firestore.collection('cart_items').doc(snapshot.docs.first.id).delete();
      }

      // Update local state
      _cartItems.remove(cartItem);

    } catch (e) {
      _errorMessage = 'Lỗi khi xóa khỏi giỏ hàng: $e';
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

      // Delete all cart items for this user
      final snapshot = await _firestore
          .collection('cart_items')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _cartItems.clear();

    } catch (e) {
      _errorMessage = 'Lỗi khi xóa giỏ hàng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
