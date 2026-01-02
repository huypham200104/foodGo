import 'package:flutter_test/flutter_test.dart';
import 'package:foodgo/models/order_model.dart';
import 'package:foodgo/models/user_model.dart';
import 'package:foodgo/models/cart_item_model.dart';
import 'package:foodgo/models/menu_item_model.dart';
import 'package:foodgo/utils/reward_calculator.dart';

void main() {
  group('RewardCalculator Tests', () {
    // Mock Data
    final mockUserBronze = UserModel(
      id: 'u1',
      name: 'User Bronze',
      email: 'bronze@test.com',
      membershipLevel: 'Bronze',
      totalEarnedPoints: 100,
    );

    final mockUserSilver = UserModel(
      id: 'u2',
      name: 'User Silver',
      email: 'silver@test.com',
      membershipLevel: 'Silver',
      totalEarnedPoints: 500,
    );



    final mockUserPlatinum = UserModel(
      id: 'u4',
      name: 'User Platinum',
      email: 'platinum@test.com',
      membershipLevel: 'Platinum',
      totalEarnedPoints: 2500,
    );

    final normalItem = MenuItemModel(
      id: 'i1',
      name: 'Normal Item',
      description: 'Desc',
      price: 50000,
      imageUrl: 'url',
      category: 'food',
      isNew: false,
    );

    final newItem = MenuItemModel(
      id: 'i2',
      name: 'New Item',
      description: 'Desc',
      price: 60000,
      imageUrl: 'url',
      category: 'food',
      isNew: true,
    );

    final comboItem = MenuItemModel(
      id: 'i3',
      name: 'Combo Item',
      description: 'Desc',
      price: 100000,
      imageUrl: 'url',
      category: 'combo',
      isNew: false,
    );

    test('Calculate points for standard order (Bronze User)', () {
      final order = OrderModel(
        id: 'o1',
        status: 'delivered',
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Rest 1',
        items: [CartItemModel(item: normalItem, quantity: 2)], // 100k
        deliveryFee: 15000,
        totalPrice: 100000,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );

      // Base: 100000 / 1000 = 100
      // Category: x1.0
      // Tier: +0%
      // Total: 100
      final points = RewardCalculator.calculateEarnedPoints(order, mockUserBronze);
      expect(points, 100);
    });

    test('Calculate points for Silver User (+5%)', () {
      final order = OrderModel(
        id: 'o2',
        status: 'delivered',
        userId: 'u2',
        restaurantId: 'r1',
        restaurantName: 'Rest 1',
        items: [CartItemModel(item: normalItem, quantity: 2)], // 100k
        deliveryFee: 15000,
        totalPrice: 100000,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );

      // Base: 100
      // Category: x1.0
      // Tier: +5% -> 1.05
      // Total: 100 * 1.05 = 105
      final points = RewardCalculator.calculateEarnedPoints(order, mockUserSilver);
      expect(points, 105);
    });

    test('Calculate points with New Item (x1.1)', () {
      final order = OrderModel(
        id: 'o3',
        status: 'delivered',
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Rest 1',
        items: [CartItemModel(item: newItem, quantity: 1)], // 60k
        deliveryFee: 15000,
        totalPrice: 60000,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );

      // Base: 60
      // Category: x1.1
      // Tier: +0%
      // Total: 60 * 1.1 = 66
      final points = RewardCalculator.calculateEarnedPoints(order, mockUserBronze);
      expect(points, 66);
    });

    test('Calculate points with Combo (x1.2)', () {
      final order = OrderModel(
        id: 'o4',
        status: 'delivered',
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Rest 1',
        items: [CartItemModel(item: comboItem, quantity: 1)], // 100k
        deliveryFee: 15000,
        totalPrice: 100000,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );

      // Base: 100
      // Category: x1.2
      // Tier: +0%
      // Total: 100 * 1.2 = 120
      final points = RewardCalculator.calculateEarnedPoints(order, mockUserBronze);
      expect(points, 120);
    });

    test('Calculate points for Platinum User with Combo (+15% & x1.2)', () {
      final order = OrderModel(
        id: 'o5',
        status: 'delivered',
        userId: 'u4',
        restaurantId: 'r1',
        restaurantName: 'Rest 1',
        items: [CartItemModel(item: comboItem, quantity: 2)], // 200k
        deliveryFee: 15000,
        totalPrice: 200000,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      );

      // Base: 200
      // Category: x1.2
      // Tier: +15% -> 1.15
      // Total: 200 * 1.2 * 1.15 = 240 * 1.15 = 276
      final points = RewardCalculator.calculateEarnedPoints(order, mockUserPlatinum);
      expect(points, 276);
    });

    test('Tier Calculation Logic', () {
      expect(RewardCalculator.calculateTier(0), 'Bronze');
      expect(RewardCalculator.calculateTier(299), 'Bronze');
      expect(RewardCalculator.calculateTier(300), 'Silver');
      expect(RewardCalculator.calculateTier(999), 'Silver');
      expect(RewardCalculator.calculateTier(1000), 'Gold');
      expect(RewardCalculator.calculateTier(1999), 'Gold');
      expect(RewardCalculator.calculateTier(2000), 'Platinum');
      expect(RewardCalculator.calculateTier(5000), 'Platinum');
    });
  });
}
