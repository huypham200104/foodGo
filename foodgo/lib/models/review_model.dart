import 'user_model.dart';

class ReviewModel {
  final String id;
  final String restaurantId;
  final String menuItemId;
  final UserModel user;
  final int stars;
  final String comment;
  final List<String> images;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.menuItemId,
    required this.user,
    required this.stars,
    required this.comment,
    this.images = const [],
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] ?? '',
    restaurantId: json['restaurantId'] ?? '',
    menuItemId: json['menuItemId'] ?? '',
    user: UserModel.fromJson(json['user']),
    stars: json['stars'] ?? 0,
    comment: json['comment'] ?? '',
    images:
    (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
    date: DateTime.parse(json['date']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'menuItemId': menuItemId,
    'user': user.toJson(),
    'stars': stars,
    'comment': comment,
    'images': images,
    'date': date.toIso8601String(),
  };
}
