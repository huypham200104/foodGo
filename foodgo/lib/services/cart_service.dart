import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('cart_items');

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamCartDocs(
    String userId,
  ) {
    // Bỏ orderBy để tránh cần index, có thể sort ở client side nếu cần
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          // Sort by createdAt nếu có, nếu không thì giữ nguyên thứ tự
          final docs = snap.docs.toList();
          docs.sort((a, b) {
            final aCreatedAt = a.data()['createdAt'];
            final bCreatedAt = b.data()['createdAt'];
            if (aCreatedAt == null && bCreatedAt == null) return 0;
            if (aCreatedAt == null) return 1;
            if (bCreatedAt == null) return -1;
            if (aCreatedAt is Timestamp && bCreatedAt is Timestamp) {
              return aCreatedAt.compareTo(bCreatedAt);
            }
            return 0;
          });
          return docs;
        });
  }

  Future<String> addItem({
    required String userId,
    required CartItemModel cartItem,
  }) async {
    final docRef = await _collection.add({
      ...cartItem.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateQuantity({
    required String docId,
    required int quantity,
  }) async {
    await _collection.doc(docId).update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeItem({
    required String docId,
  }) async {
    await _collection.doc(docId).delete();
  }

  Future<void> clearCart({
    required String userId,
  }) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}



