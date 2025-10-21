import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'widgets/menu_category_tabs.dart';
import 'widgets/menu_item_card.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  static const List<String> kCategories = <String>[
    'burger',
    'chicken',
    'noodle',
    'side',
    'dessert',
    'drink',
    'combo',
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: kCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực Đơn'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: MenuCategoryTabs(
            controller: _tabController,
            categories: const [
              'BURGER',
              'GÀ',
              'MỲ',
              'MÓN KÈM',
              'TRÁNG MIỆNG',
              'ĐỒ UỐNG',
              'COMBO',
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: kCategories.map((cat) => _MenuList(category: cat)).toList(),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final String category;
  const _MenuList({required this.category});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('menu_items')
        .where('category', isEqualTo: category);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có món trong danh mục này'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return MenuItemCard(data: data);
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: docs.length,
        );
      },
    );
  }
}


