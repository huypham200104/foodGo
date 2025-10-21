import 'package:flutter/material.dart';

class MenuCategoryTabs extends StatelessWidget {
  final TabController controller;
  final List<String> categories;

  const MenuCategoryTabs({super.key, required this.controller, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: true,
        controller: controller,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        tabs: [for (final c in categories) Tab(text: c)],
      ),
    );
  }
}


