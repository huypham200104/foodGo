import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/restaurant_model.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CheckoutService {
  static const double defaultDeliveryFee = 15000.0;
  
  static Future<String> processOrder({
    required CartProvider cartProvider,
    required AuthProvider authProvider,
    required AddressModel deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    // Validate inputs
    if (authProvider.currentUser == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    if (cartProvider.items.isEmpty) {
      throw Exception('Giỏ hàng trống');
    }

    // Get restaurant info
    final restaurantId = cartProvider.items.first.item.restaurantId;
    if (restaurantId.isEmpty) {
      throw Exception('Không tìm thấy thông tin nhà hàng');
    }

    // Fetch restaurant data
    final restaurant = await _getRestaurantById(restaurantId);
    
    // Create order
    final order = OrderModel(
      id: '', // Will be set by Firestore
      status: 'pending',
      userId: authProvider.currentUser!.id,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantImage: restaurant.imageUrl,
      items: cartProvider.items,
      deliveryFee: defaultDeliveryFee,
      totalPrice: cartProvider.totalPrice,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      note: notes ?? '',
      deliveryAddress: deliveryAddress,
      estimatedDeliveryTime: 30,
    );

    // Save to Firestore
    final docRef = await FirebaseFirestore.instance
        .collection('orders')
        .add(order.toJson());

    // Update order with generated ID
    await docRef.update({'id': docRef.id});

    // Clear cart
    await cartProvider.clearCart(authProvider.currentUser!.id);

    return docRef.id;
  }

  static Future<RestaurantModel> _getRestaurantById(String restaurantId) async {
    final doc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .get();

    if (!doc.exists) {
      throw Exception('Không tìm thấy nhà hàng');
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return RestaurantModel.fromJson(data);
  }
}