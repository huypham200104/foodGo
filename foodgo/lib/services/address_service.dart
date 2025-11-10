import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class AddressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'addresses';

  // Get all addresses for a specific user
  static Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách địa chỉ: $e');
    }
  }

  // Get default address for a user
  static Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return AddressModel.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi tải địa chỉ mặc định: $e');
    }
  }

  // Add new address
  static Future<void> addAddress(AddressModel address) async {
    try {
      final batch = _firestore.batch();
      
      // If this address is default, unset other default addresses first
      if (address.isDefault) {
        final defaultAddresses = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: address.userId)
            .where('isDefault', isEqualTo: true)
            .get();

        for (var doc in defaultAddresses.docs) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }

      // Add new address
      final newAddressRef = _firestore.collection(_collectionName).doc();
      final addressData = address.toFirestore();
      addressData['createdAt'] = FieldValue.serverTimestamp();
      addressData['updatedAt'] = FieldValue.serverTimestamp();
      
      batch.set(newAddressRef, addressData);

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi khi thêm địa chỉ: $e');
    }
  }

  // Update existing address
  static Future<void> updateAddress(AddressModel address) async {
    try {
      final batch = _firestore.batch();
      
      // If this address is being set as default, unset other defaults first
      if (address.isDefault) {
        final defaultAddresses = await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: address.userId)
            .where('isDefault', isEqualTo: true)
            .get();

        for (var doc in defaultAddresses.docs) {
          if (doc.id != address.id) {
            batch.update(doc.reference, {'isDefault': false});
          }
        }
      }

      // Update the address
      final addressRef = _firestore.collection(_collectionName).doc(address.id);
      final addressData = address.toFirestore();
      addressData['updatedAt'] = FieldValue.serverTimestamp();
      
      batch.update(addressRef, addressData);

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật địa chỉ: $e');
    }
  }

  // Delete address
  static Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection(_collectionName).doc(addressId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa địa chỉ: $e');
    }
  }

  // Set default address
  static Future<void> setDefaultAddress(String addressId) async {
    try {
      // First, get the address to know the userId
      final addressDoc = await _firestore
          .collection(_collectionName)
          .doc(addressId)
          .get();

      if (!addressDoc.exists) {
        throw Exception('Địa chỉ không tồn tại');
      }

      final userId = addressDoc.data()?['userId'];
      if (userId == null) {
        throw Exception('Không tìm thấy userId');
      }

      final batch = _firestore.batch();

      // Unset all default addresses for this user
      final userAddresses = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .get();

      for (var doc in userAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set the new default address
      final addressRef = _firestore.collection(_collectionName).doc(addressId);
      batch.update(addressRef, {
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi khi đặt địa chỉ mặc định: $e');
    }
  }

  // Get addresses stream (for real-time updates)
  static Stream<List<AddressModel>> getUserAddressesStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Check if user has any addresses
  static Future<bool> hasAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get address by ID
  static Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(addressId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AddressModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi tải địa chỉ: $e');
    }
  }

  // Batch delete all addresses for a user (useful when deleting account)
  static Future<void> deleteAllUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả địa chỉ: $e');
    }
  }

  // Validate address data before saving
  static bool isValidAddress(AddressModel address) {
    return address.name?.isNotEmpty == true &&
           address.phone?.isNotEmpty == true &&
           address.detail?.isNotEmpty == true &&
           address.userId?.isNotEmpty == true;
  }
}