import 'package:flutter/material.dart';

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

  // Method để get color theo category
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
