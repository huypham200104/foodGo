import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/menu_item_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Import menu items to Firestore
  static Future<void> importMenuItems(List<MenuItemModel> menuItems) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (MenuItemModel item in menuItems) {
        DocumentReference docRef = _firestore.collection('menu_items').doc(item.id);
        batch.set(docRef, item.toJson());
      }
      
      await batch.commit();
      print('✅ Successfully imported ${menuItems.length} menu items to Firestore');
    } catch (e) {
      print('❌ Error importing menu items: $e');
      rethrow;
    }
  }
  
  // Get all menu items from Firestore
  static Future<List<MenuItemModel>> getMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MenuItemModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting menu items: $e');
      rethrow;
    }
  }
  
  // Clear all menu items from Firestore
  static Future<void> clearMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
      WriteBatch batch = _firestore.batch();
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Successfully cleared all menu items from Firestore');
    } catch (e) {
      print('❌ Error clearing menu items: $e');
      rethrow;
    }
  }
}
