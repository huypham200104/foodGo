import 'package:flutter/material.dart';
import '../../../services/menu_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class CategoryIcons extends StatelessWidget {
  final Function(String)? onCategoryTap;
  
  const CategoryIcons({
    super.key,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: MenuService.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: ScreenService.largeSpacing * 3);
        }

        final categories = snapshot.data!;
        return Container(
          height: ScreenService.largeSpacing * 3,
          padding: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: ScreenService.smallSpacing),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryColor = AppIcons.getCategoryColor(category['id']);
              
              return GestureDetector(
                onTap: () => onCategoryTap?.call(category['id']),
                child: Container(
                  width: ScreenService.widthPercent(18),
                  margin: EdgeInsets.only(right: ScreenService.smallSpacing),
                  child: Column(
                    children: [
                      Container(
                        width: ScreenService.buttonHeight,
                        height: ScreenService.buttonHeight,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                        ),
                        child: Icon(
                          AppIcons.getIconData(category['id']),
                          color: categoryColor,
                          size: ScreenService.largeText,
                        ),
                      ),
                      SizedBox(height: ScreenService.smallSpacing / 2),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: ScreenService.smallText,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AppIcons {
  // Bottom Navigation Icons
  static const IconData home = Icons.home;
  static const IconData notification = Icons.notifications;
  static const IconData cart = Icons.shopping_cart;
  static const IconData profile = Icons.person;
  
  // Category Icons  
  static const IconData pizza = Icons.local_pizza;
  static const IconData drink = Icons.local_drink;
  static const IconData cake = Icons.cake;
  static const IconData burger = Icons.lunch_dining;
  static const IconData fastfood = Icons.fastfood;
  static const IconData restaurant = Icons.restaurant;
  static const IconData coffee = Icons.local_cafe;
  static const IconData icecream = Icons.icecream;
  static const IconData noodles = Icons.ramen_dining;
  static const IconData chicken = Icons.set_meal;
  static const IconData salad = Icons.eco;
  static const IconData seafood = Icons.phishing;
  
  // Other Icons
  static const IconData search = Icons.search;
  static const IconData favorite = Icons.favorite;
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData star = Icons.star;
  static const IconData location = Icons.location_on;

  // Method để get icon theo category ID
  static IconData getIconData(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'pizza':
        return pizza;
      case 'burger':
      case 'burgers':
        return burger;
      case 'drink':
      case 'drinks':
      case 'beverages':
        return drink;
      case 'cake':
      case 'cakes':
      case 'dessert':
      case 'desserts':
        return cake;
      case 'coffee':
        return coffee;
      case 'fastfood':
      case 'fast_food':
        return fastfood;
      case 'ice_cream':
      case 'icecream':
        return icecream;
      case 'noodles':
      case 'pasta':
      case 'ramen':
        return noodles;
      case 'chicken':
      case 'meat':
        return chicken;
      case 'salad':
      case 'healthy':
      case 'vegetarian':
        return salad;
      case 'seafood':
      case 'fish':
        return seafood;
      case 'restaurant':
      default:
        return restaurant; // Default icon
    }
  }

  // Method để get color theo category (optional)
  static Color getCategoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'pizza':
        return Colors.red;
      case 'burger':
      case 'burgers':
        return Colors.orange;
      case 'drink':
      case 'drinks':
      case 'beverages':
        return Colors.blue;
      case 'cake':
      case 'cakes':
      case 'dessert':
      case 'desserts':
        return Colors.pink;
      case 'coffee':
        return Colors.brown;
      case 'fastfood':
      case 'fast_food':
        return Colors.green;
      case 'ice_cream':
      case 'icecream':
        return Colors.purple;
      case 'noodles':
      case 'pasta':
      case 'ramen':
        return Colors.amber;
      case 'chicken':
      case 'meat':
        return Colors.deepOrange;
      case 'salad':
      case 'healthy':
      case 'vegetarian':
        return Colors.lightGreen;
      case 'seafood':
      case 'fish':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}

