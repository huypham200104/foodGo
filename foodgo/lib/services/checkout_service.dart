import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CheckoutService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Process order with optional custom order ID
  static Future<String> processOrder({
    required CartProvider cartProvider,
    required AuthProvider authProvider,
    required AddressModel deliveryAddress,
    required String paymentMethod,
    String notes = '',
    String? customOrderId,
  }) async {
    try {
      final user = authProvider.currentUser!;
      final orderId = customOrderId ?? _generateOrderId();
      
      // 👈 FIXED: Use correct methods from models
      final orderData = {
        'id': orderId,
        'userId': user.id,
        'items': cartProvider.items.map((cartItem) => {
          'menuItemId': cartItem.item.id,           // 👈 cartItem.item.id
          'name': cartItem.item.name,               // 👈 cartItem.item.name  
          'price': cartItem.item.price,             // 👈 cartItem.item.price
          'quantity': cartItem.quantity,            // 👈 cartItem.quantity
          'note': cartItem.note,                    // 👈 cartItem.note
          'selectedToppings': cartItem.selectedToppings, // 👈 cartItem.selectedToppings
          'totalPrice': cartItem.totalPrice,        // 👈 cartItem.totalPrice
        }).toList(),
        'totalAmount': cartProvider.totalPrice,
        'deliveryFee': 0,
        'finalAmount': cartProvider.totalPrice + 0,
        'paymentMethod': paymentMethod,
        'orderStatus': 'pending',
        'paymentStatus': paymentMethod == 'bank_transfer' ? 'pending' : 'paid',
        'deliveryAddress': deliveryAddress.toJson(), // 👈 Use toJson() instead of toMap()
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDeliveryTime': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
        
        // 👈 Add missing fields for OrderModel compatibility
        'status': 'pending',
        'restaurantId': _getRestaurantIdFromItems(cartProvider.items),
        'restaurantName': _getRestaurantNameFromItems(cartProvider.items),
        'restaurantImage': null,
        'totalPrice': cartProvider.totalPrice,
        'deliveryFee': 0.0,
        'note': notes, // 👈 Note for OrderModel (singular)
      };

      // Save to Firestore
      await _firestore.collection('orders').doc(orderId).set(orderData);

      return orderId;
    } catch (e) {
      throw Exception('Lỗi khi xử lý đơn hàng: $e');
    }
  }

  /// Generate unique order ID
  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD_$timestamp';
  }

  /// Get restaurant ID from cart items (assuming all items from same restaurant)
  static String _getRestaurantIdFromItems(List<dynamic> items) {
    if (items.isNotEmpty) {
      // MenuItemModel has restaurantId field
      return items.first.item.restaurantId ?? 'default_restaurant';
    }
    return 'default_restaurant';
  }

  /// Get restaurant name from cart items
  static String _getRestaurantNameFromItems(List<dynamic> items) {
    // MenuItemModel does NOT have restaurantName field
    // Return default value instead
    return 'FoodGo Restaurant';
  }

  /// Get order by ID
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromFirestore(doc.data()!, doc.id); // 👈 Use fromFirestore()
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin đơn hàng: $e');
    }
  }

  /// Get orders for user
  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id)) // 👈 Use fromFirestore()
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đơn hàng: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status, // 👈 Use 'status' field name from OrderModel
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái đơn hàng: $e');
    }
  }

  /// Update payment status
  static Future<void> updatePaymentStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái thanh toán: $e');
    }
  }

  /// Create order directly from cart for better compatibility
  static Future<String> createOrderFromCart({
    required CartProvider cartProvider,
    required AuthProvider authProvider,
    required AddressModel deliveryAddress,
    required String paymentMethod,
    String notes = '',
    String? customOrderId,
  }) async {
    try {
      final user = authProvider.currentUser!;
      final orderId = customOrderId ?? _generateOrderId();
      
      // 👈 Create OrderModel directly for better type safety
      final order = OrderModel(
        id: orderId,
        status: 'pending',
        userId: user.id,
        restaurantId: _getRestaurantIdFromItems(cartProvider.items),
        restaurantName: _getRestaurantNameFromItems(cartProvider.items),
        restaurantImage: null,
        items: cartProvider.items,
        deliveryFee: 0.0,
        totalPrice: cartProvider.totalPrice,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        note: notes,
        deliveryAddress: deliveryAddress,
        estimatedDeliveryTime: 30,
      );

      // Save using OrderModel's toFirestore method
      await _firestore.collection('orders').doc(orderId).set(order.toFirestore());

      return orderId;
    } catch (e) {
      throw Exception('Lỗi khi tạo đơn hàng: $e');
    }
  }

  /// Get order summary for display
  static Map<String, dynamic> getOrderSummary(
    CartProvider cartProvider,
    AddressModel deliveryAddress,
    String paymentMethod,
  ) {
    return {
      'itemCount': cartProvider.items.length,
      'totalItems': cartProvider.items.fold(0, (sum, item) => sum + item.quantity),
      'subtotal': cartProvider.totalPrice,
      'deliveryFee': 0.0,
      'total': cartProvider.totalPrice + 0.0,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress.displayAddress,
      'deliveryPhone': deliveryAddress.safePhone,
      'deliveryName': deliveryAddress.displayName,
    };
  }

  /// Validate order before processing
  static bool validateOrder({
    required CartProvider cartProvider,
    required AddressModel deliveryAddress,
    required String paymentMethod,
  }) {
    // Check cart not empty
    if (cartProvider.items.isEmpty) return false;
    
    // Check address is complete
    if (!deliveryAddress.isComplete) return false;
    
    // Check payment method is valid
    if (!['cash', 'bank_transfer', 'card'].contains(paymentMethod)) return false;
    
    return true;
  }
}