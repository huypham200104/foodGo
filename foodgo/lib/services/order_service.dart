import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'orders';

  /// Lấy tất cả đơn hàng của user
  static Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .where((doc) => doc.data().isNotEmpty) // Ensure data exists
          .map((doc) {
            final data = doc.data();
            return OrderModel.fromFirestore(data, doc.id);
          })
          .toList();
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      throw Exception('Không thể tải đơn hàng: $e');
    }
  }

  /// Lấy đơn hàng theo ID
  static Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(orderId)
          .get();

      if (doc.exists && doc.data() != null) {
        return OrderModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order by ID: $e');
      throw Exception('Không thể tải thông tin đơn hàng: $e');
    }
  }

  /// Lấy đơn hàng theo trạng thái
  static Future<List<OrderModel>> getUserOrdersByStatus(
    String userId,
    String status,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .where((doc) => doc.data().isNotEmpty)
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting orders by status: $e');
      throw Exception('Không thể tải đơn hàng theo trạng thái: $e');
    }
  }

  /// Tạo đơn hàng mới
  static Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(order.toFirestore());
      
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Không thể tạo đơn hàng: $e');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error updating order status: $e');
      throw Exception('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  /// Hủy đơn hàng
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
            'status': 'cancelled',
            'cancelReason': reason,
            'cancelledAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      throw Exception('Không thể hủy đơn hàng: $e');
    }
  }

  /// Đánh giá đơn hàng
  static Future<void> rateOrder(
    String orderId,
    double rating,
    String? comment,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
            'rating': rating,
            'review': comment,
            'ratedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error rating order: $e');
      throw Exception('Không thể đánh giá đơn hàng: $e');
    }
  }

  /// Kiểm tra xem có thể hủy đơn hàng không
  static bool canCancelOrder(OrderModel order) {
    return order.canCancel;
  }

  /// Kiểm tra xem có thể đánh giá đơn hàng không
  static bool canRateOrder(OrderModel order) {
    return order.canRate;
  }

  /// Kiểm tra xem có thể đặt lại đơn hàng không
  static bool canReorder(OrderModel order) {
    return order.canReorder;
  }
}

