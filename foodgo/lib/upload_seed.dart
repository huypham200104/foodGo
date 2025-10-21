import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> _readArray(String assetPath, String rootKey) async {
  final String jsonString = await rootBundle.loadString(assetPath);
  final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
  final list = data[rootKey];
  if (list is List) return list;
  return const [];
}

Future<void> uploadUsers() async {
  final firestore = FirebaseFirestore.instance;
  final users = await _readArray('assets/data/users.json', 'users');
  for (final u in users) {
    final id = (u['id'] ?? '').toString();
    await firestore.collection('users').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(u));
  }
}

Future<void> uploadAddresses() async {
  final firestore = FirebaseFirestore.instance;
  final addresses = await _readArray('assets/data/addresses.json', 'addresses');
  for (final a in addresses) {
    final id = (a['id'] ?? '').toString();
    await firestore.collection('addresses').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(a));
  }
}

Future<void> uploadRestaurants() async {
  final firestore = FirebaseFirestore.instance;
  final restaurants = await _readArray('assets/data/restaurants.json', 'restaurants');
  for (final r in restaurants) {
    final id = (r['id'] ?? '').toString();
    await firestore.collection('restaurants').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(r));
  }
}

// Option A: menu_items aligned to MenuItemModel
Future<void> uploadMenuItems() async {
  final firestore = FirebaseFirestore.instance;
  final menu = await _readArray('assets/data/menu_items.json', 'menu');
  for (final m in menu) {
    final id = (m['id'] ?? '').toString();
    await firestore.collection('menu_items').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(m));
  }
}

Future<void> uploadVouchers() async {
  final firestore = FirebaseFirestore.instance;
  final vouchers = await _readArray('assets/data/vouchers.json', 'vouchers');
  for (final v in vouchers) {
    final id = (v['id'] ?? '').toString();
    await firestore.collection('vouchers').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(v));
  }
}

Future<void> uploadRewards() async {
  final firestore = FirebaseFirestore.instance;
  final rewards = await _readArray('assets/data/rewards.json', 'rewards');
  for (final r in rewards) {
    await firestore.collection('rewards').add(Map<String, dynamic>.from(r));
  }
}

Future<void> uploadCartItems() async {
  final firestore = FirebaseFirestore.instance;
  final cartItems = await _readArray('assets/data/cart_items.json', 'cartItems');
  for (final c in cartItems) {
    final id = (c['id'] ?? '').toString();
    await firestore.collection('cart_items').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(c));
  }
}

Future<void> uploadOrders() async {
  final firestore = FirebaseFirestore.instance;
  final orders = await _readArray('assets/data/orders.json', 'orders');
  for (final o in orders) {
    final id = (o['id'] ?? '').toString();
    await firestore.collection('orders').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(o));
  }
}

Future<void> uploadReviews() async {
  final firestore = FirebaseFirestore.instance;
  final reviews = await _readArray('assets/data/reviews.json', 'reviews');
  for (final r in reviews) {
    final id = (r['id'] ?? '').toString();
    await firestore.collection('reviews').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(r));
  }
}

Future<void> uploadComplaints() async {
  final firestore = FirebaseFirestore.instance;
  final complaints = await _readArray('assets/data/complaints.json', 'complaints');
  for (final c in complaints) {
    final id = (c['id'] ?? '').toString();
    await firestore.collection('complaints').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(c));
  }
}

Future<void> uploadAllSeeds() async {
  await Future.wait([
    uploadUsers(),
    uploadAddresses(),
    uploadRestaurants(),
    uploadMenuItems(),
    uploadVouchers(),
    uploadRewards(),
    uploadCartItems(),
    uploadOrders(),
    uploadReviews(),
    uploadComplaints(),
  ]);
}


