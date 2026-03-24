import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.color = Colors.blue,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: _iconFromString(json['icon']),
      color: _colorFromString(json['color'] ?? 'blue'),
    );
  }

  static IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'all_inclusive':
        return Icons.all_inclusive;
      case 'computer':
        return Icons.computer;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'face_retouching_natural':
        return Icons.face_retouching_natural;
      default:
        return Icons.category;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': _iconToString(icon),
      'color': _colorToString(color),
    };
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.all_inclusive) return 'all_inclusive';
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.face_retouching_natural) return 'face_retouching_natural';
    return 'category';
  }
  
  static String _colorToString(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.green) return 'green';
    return 'blue'; // Par défaut
  }
  
  static Color _colorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
      default:
        return Colors.blue;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
