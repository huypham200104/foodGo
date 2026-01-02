import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/reward_calculator.dart';
import 'user_service.dart';

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
    // This method seems redundant if we use createOrderFromCart, 
    // but keeping it for backward compatibility if used elsewhere.
    // For now, redirect to createOrderFromCart
    return createOrderFromCart(
      cartProvider: cartProvider,
      authProvider: authProvider,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      customOrderId: customOrderId,
    );
  }

  /// Generate unique order ID
  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD_$timestamp';
  }

  /// Get restaurant ID from cart items (assuming all items from same restaurant)
  static String _getRestaurantIdFromItems(List<dynamic> items) {
    if (items.isNotEmpty) {
      return items.first.item.restaurantId ?? 'default_restaurant';
    }
    return 'default_restaurant';
  }

  /// Get restaurant name from cart items
  static String _getRestaurantNameFromItems(List<dynamic> items) {
    return 'FoodGo Restaurant';
  }

  /// Get order by ID
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromFirestore(doc.data()!, doc.id);
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
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đơn hàng: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✨ Award points only when order is delivered
      if (status == 'delivered') {
        await _awardPointsForDeliveredOrder(orderId);
      }
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

  /// Create order directly from cart
  static Future<String> createOrderFromCart({
    required CartProvider cartProvider,
    required AuthProvider authProvider,
    required AddressModel deliveryAddress,
    required String paymentMethod,
    String notes = '',
    String? customOrderId,
    // ✨ New parameters
    double discount = 0.0,
    String? voucherCode,
    String deliveryMethod = 'delivery',
    String status = 'pending', // ✨ Add status parameter
  }) async {
    try {
      final user = authProvider.currentUser!;
      final orderId = customOrderId ?? _generateOrderId();
      
      // ✨ Calculate points
      final tempOrder = OrderModel(
        id: orderId,
        status: status, // ✨ Use passed status
        userId: user.id,
        restaurantId: '',
        restaurantName: '',
        items: cartProvider.items,
        deliveryFee: deliveryMethod == 'delivery' ? 30000 : 0,
        totalPrice: cartProvider.totalPrice,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        discount: discount,
      );
      
      final earnedPoints = RewardCalculator.calculateEarnedPoints(tempOrder, user);

      // 👈 Create OrderModel directly for better type safety
      final order = OrderModel(
        id: orderId,
        status: status, // ✨ Use passed status
        userId: user.id,
        restaurantId: _getRestaurantIdFromItems(cartProvider.items),
        restaurantName: _getRestaurantNameFromItems(cartProvider.items),
        restaurantImage: null,
        items: cartProvider.items,
        deliveryFee: deliveryMethod == 'delivery' ? 30000.0 : 0.0, // ✨ Fixed fee logic
        totalPrice: cartProvider.totalPrice,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        note: notes,
        deliveryAddress: deliveryAddress,
        estimatedDeliveryTime: 30,
        // ✨ New fields
        discount: discount,
        voucherCode: voucherCode,
        earnedPoints: earnedPoints,
        deliveryMethod: deliveryMethod,
      );

      // Save using OrderModel's toFirestore method
      await _firestore.collection('orders').doc(orderId).set(order.toFirestore());

      // Update user's order statistics (totalSpent, totalOrders, membership level)
      await UserService.updateOrderStats(user.id, order.totalAmount);

      // ✨ Points will be awarded only when order status changes to 'delivered'
      // Not awarding points here to prevent premature point accumulation

      return orderId;
    } catch (e) {
      throw Exception('Lỗi khi tạo đơn hàng: $e');
    }
  }

  // ✨ Award points when order is delivered
  static Future<void> _awardPointsForDeliveredOrder(String orderId) async {
    try {
      // Get order details
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return;
      
      final order = OrderModel.fromFirestore(orderDoc.data()!, orderDoc.id);
      
      // Get user details
      final userDoc = await _firestore.collection('users').doc(order.userId).get();
      if (!userDoc.exists) return;
      
      final userData = userDoc.data()!;
      final currentTotalEarned = userData['totalEarnedPoints'] ?? 0;
      final currentRewardPoints = userData['rewardPoints'] ?? 0;
      
      // Calculate earned points for this order
      final earnedPoints = order.earnedPoints;
      if (earnedPoints <= 0) return;
      
      // Update user rewards
      final newTotalEarned = currentTotalEarned + earnedPoints;
      final newCurrentPoints = currentRewardPoints + earnedPoints;
      
      // Calculate new tier
      final newTier = RewardCalculator.calculateTier(newTotalEarned);
      
      // Update user document
      await _firestore.collection('users').doc(order.userId).update({
        'totalEarnedPoints': newTotalEarned,
        'rewardPoints': newCurrentPoints,
        'membershipLevel': newTier,
      });
    } catch (e) {
      debugPrint('Error awarding points for delivered order: $e');
      // Don't throw, just log - points award failure shouldn't break order status update
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
    if (cartProvider.items.isEmpty) return false;
    if (!deliveryAddress.isComplete) return false;
    if (!['cash', 'bank_transfer', 'card'].contains(paymentMethod)) return false;
    return true;
  }
}

