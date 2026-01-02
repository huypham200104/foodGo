import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodgo/models/menu_item_model.dart';
import '../core/constans/app_icons.dart';
import '../services/firebase_service.dart';

class MenuService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static List<MenuItemModel>? _cachedMenu;
  static Map<String, dynamic>? _cachedMetadata;
  
  // 👈 Thêm cache cho new products và bestsellers
  static List<MenuItemModel>? _cachedNewProducts;
  static List<MenuItemModel>? _cachedBestsellerProducts;

  /// Load menu data từ Firebase Firestore
  static Future<List<MenuItemModel>> loadMenuData() async {
    if (_cachedMenu != null) {
      return _cachedMenu!;
    }

    try {
      // Load từ Firebase collection 'menu_items'
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .get();

      _cachedMenu = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return MenuItemModel.fromJson(data);
      }).toList();

      return _cachedMenu!;
    } catch (e) {
      debugPrint('Error loading menu data from Firebase: $e');
      
      // Fallback to local JSON file
      return await _loadMenuFromLocal();
    }
  }

  /// Fallback: Load từ local JSON file
  static Future<List<MenuItemModel>> _loadMenuFromLocal() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/menu_items.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> menuList = jsonData['menu'];
      _cachedMenu = menuList.map((item) => MenuItemModel.fromJson(item)).toList();
      _cachedMetadata = jsonData['metadata'];
      
      return _cachedMenu!;
    } catch (e) {
      debugPrint('Error loading menu data from local: $e');
      return [];
    }
  }

  /// Lấy sản phẩm mới từ Firebase
  static Future<List<MenuItemModel>> getNewProducts() async {
    // 👈 Sử dụng cache
    if (_cachedNewProducts != null) {
      return _cachedNewProducts!;
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .where('isNew', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        _cachedNewProducts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return MenuItemModel.fromJson(FirebaseService.convertFirestoreData(data));
        }).toList();
        return _cachedNewProducts!;
      }

      // Fallback when no docs match
      final all = await loadMenuData();
      final candidates = all
          .where((e) => e.isAvailable && (e.isNew == true))
          .toList();
      candidates.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
      _cachedNewProducts = candidates.take(10).toList();
      return _cachedNewProducts!;
    } catch (e) {
      debugPrint('Error loading new products: $e');
      final all = await _loadMenuFromLocal();
      final candidates = all
          .where((e) => e.isAvailable && (e.isNew == true))
          .toList();
      candidates.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
      _cachedNewProducts = candidates.take(10).toList();
      return _cachedNewProducts!;
    }
  }

  /// Lấy sản phẩm bán chạy từ Firebase
  static Future<List<MenuItemModel>> getBestsellerProducts() async {
    // 👈 Sử dụng cache
    if (_cachedBestsellerProducts != null) {
      return _cachedBestsellerProducts!;
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .where('soldCount', isGreaterThanOrEqualTo: 500)
          .orderBy('soldCount', descending: true)
          .limit(10)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        _cachedBestsellerProducts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return MenuItemModel.fromJson(FirebaseService.convertFirestoreData(data));
        }).toList();
        return _cachedBestsellerProducts!;
      }

      // Fallback: sort all by soldCount desc
      final all = await loadMenuData();
      all.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
      _cachedBestsellerProducts = all.take(10).toList();
      return _cachedBestsellerProducts!;
    } catch (e) {
      debugPrint('Error loading bestseller products: $e');
      final all = await _loadMenuFromLocal();
      all.sort((a, b) => (b.soldCount).compareTo(a.soldCount));
      _cachedBestsellerProducts = all.take(10).toList();
      return _cachedBestsellerProducts!;
    }
  }

  /// Lấy sản phẩm theo category từ Firebase
  static Future<List<MenuItemModel>> getProductsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MenuItemModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error loading products by category: $e');
      
      // Fallback to local data
      final menu = await loadMenuData();
      return menu
          .where((item) => item.category == category && item.isAvailable)
          .toList();
    }
  }

  /// Search products từ Firebase
  static Future<List<MenuItemModel>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final lowerQuery = query.toLowerCase();
      
      // Firebase doesn't support case-insensitive search directly
      // So we'll load all products and filter locally
      final menu = await loadMenuData();
      
      return menu.where((item) {
        return item.isAvailable && (
          item.name.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.ingredients.any((ingredient) => 
            ingredient.toLowerCase().contains(lowerQuery))
        );
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  /// Get categories từ Firebase metadata
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Return default categories with icons
        return _getDefaultCategories();
      }
      
      final categories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Ensure category has icon - use AppIcons if not present
        if (!data.containsKey('icon')) {
          data['icon'] = AppIcons.getIconData(data['id'] ?? '');
        }
        
        return data;
      }).toList();
      
      // Add "all" category at the beginning with icon
      categories.insert(0, {
        'id': 'all', 
        'name': 'Tất cả',
        'icon': Icons.restaurant
      });
      
      return categories;
    } catch (e) {
      debugPrint('Error getting categories: $e');
      // Return default categories on error
      return _getDefaultCategories();
    }
  }

  static List<Map<String, dynamic>> _getDefaultCategories() {
    return [
      {'id': 'all', 'name': 'Tất cả', 'icon': Icons.restaurant},
      {'id': 'burger', 'name': 'Burger', 'icon': Icons.lunch_dining},
      {'id': 'chicken', 'name': 'Gà Rán', 'icon': Icons.set_meal},
      {'id': 'pizza', 'name': 'Pizza', 'icon': Icons.local_pizza},
      {'id': 'drink', 'name': 'Đồ Uống', 'icon': Icons.local_drink},
      {'id': 'dessert', 'name': 'Tráng Miệng', 'icon': Icons.cake},
      {'id': 'combo', 'name': 'Combo', 'icon': Icons.redeem},
    ];
  }

  /// Get product by ID từ Firebase - 👈 Sửa lại method này
  static Future<MenuItemModel?> getProductById(String productId) async {
    try {
      debugPrint('Getting product by ID: $productId');
      
      // 1. Tìm trong cached menu trước
      if (_cachedMenu != null) {
        try {
          final cachedProduct = _cachedMenu!.firstWhere(
            (product) => product.id == productId,
          );
          debugPrint('Found product in cached menu: ${cachedProduct.name}');
          return cachedProduct;
        } catch (e) {
          // Không tìm thấy trong cached menu
        }
      }
      
      // 2. Tìm trong cached new products
      if (_cachedNewProducts != null) {
        try {
          final cachedProduct = _cachedNewProducts!.firstWhere(
            (product) => product.id == productId,
          );
          debugPrint('Found product in cached new products: ${cachedProduct.name}');
          return cachedProduct;
        } catch (e) {
          // Không tìm thấy trong cached new products
        }
      }
      
      // 3. Tìm trong cached bestsellers
      if (_cachedBestsellerProducts != null) {
        try {
          final cachedProduct = _cachedBestsellerProducts!.firstWhere(
            (product) => product.id == productId,
          );
          debugPrint('Found product in cached bestsellers: ${cachedProduct.name}');
          return cachedProduct;
        } catch (e) {
          // Không tìm thấy trong cached bestsellers
        }
      }
      
      // 4. Load từ Firestore nếu không có trong cache
      debugPrint('Loading product from Firestore: $productId');
      final doc = await _firestore
          .collection('menu_items')
          .doc(productId)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final product = MenuItemModel.fromJson(FirebaseService.convertFirestoreData(data));
        debugPrint('Loaded product from Firestore: ${product.name}');
        return product;
      }
      
      // 5. Fallback: Load tất cả menu và tìm
      debugPrint('Fallback: Loading all menu items');
      final allMenu = await loadMenuData();
      try {
        final product = allMenu.firstWhere(
          (product) => product.id == productId,
        );
        debugPrint('Found product in all menu: ${product.name}');
        return product;
      } catch (e) {
        debugPrint('Product not found anywhere: $productId');
        return null;
      }
      
    } catch (e) {
      debugPrint('Error getting product by ID: $e');
      return null;
    }
  }

  /// Clear cache - 👈 Cập nhật để clear tất cả cache
  static void clearCache() {
    _cachedMenu = null;
    _cachedMetadata = null;
    _cachedNewProducts = null;
    _cachedBestsellerProducts = null;
  }

  /// Update product sold count (khi có order thành công)
  static Future<void> updateSoldCount(String productId, int increment) async {
    try {
      await _firestore
          .collection('menu_items')
          .doc(productId)
          .update({
            'soldCount': FieldValue.increment(increment),
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      // Clear cache để force reload
      clearCache();
    } catch (e) {
      debugPrint('Error updating sold count: $e');
    }
  }

  /// Lấy tất cả menu items
  static Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .get();
    
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MenuItemModel.fromJson(FirebaseService.convertFirestoreData(data));
      }).toList();
    } catch (e) {
      debugPrint('Error getting all menu items: $e');
      return [];
    }
  }

  /// Lấy menu items theo category
  static Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('menu_items')
          .where('isAvailable', isEqualTo: true)
          .where('category', isEqualTo: categoryId)
          .get();
    
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MenuItemModel.fromJson(FirebaseService.convertFirestoreData(data));
      }).toList();
    } catch (e) {
      debugPrint('Error getting menu items by category: $e');
      return [];
    }
  }
}

