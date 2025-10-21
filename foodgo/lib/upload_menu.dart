import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadMenuToFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Đọc file JSON trong thư mục assets (bạn sẽ add ở bước 3)
  final String jsonString = await rootBundle.loadString('assets/data/menu.json');
  final Map<String, dynamic> data = json.decode(jsonString);
  final List<dynamic> menuItems = data['menu'];

  for (var item in menuItems) {
    await firestore.collection('menu').doc(item['id'].toString()).set({
      'group': item['group'],
      'name': item['name'],
      'description': item['description'],
      'price': item['price'],
      'options': item['options'],
    });
    print('✅ Đã upload: ${item['name']}');
  }

  print('🎉 Tải lên Firestore hoàn tất!');
}
