import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  static List<Category> get allCategories => [
    Category(
      id: 'high-tech',
      name: 'High-Tech',
      icon: Icons.computer,
      color: Colors.blue,
    ),
    Category(
      id: 'informatique',
      name: 'Informatique',
      icon: Icons.laptop,
      color: Colors.green,
    ),
    Category(
      id: 'mode',
      name: 'Mode',
      icon: Icons.style,
      color: Colors.pink,
    ),
    Category(
      id: 'maison',
      name: 'Maison',
      icon: Icons.home,
      color: Colors.orange,
    ),
    Category(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports,
      color: Colors.red,
    ),
    Category(
      id: 'voyages',
      name: 'Voyages',
      icon: Icons.flight,
      color: Colors.purple,
    ),
    Category(
      id: 'restauration',
      name: 'Restauration',
      icon: Icons.restaurant,
      color: Colors.brown,
    ),
    Category(
      id: 'beaute',
      name: 'Beauté',
      icon: Icons.spa,
      color: Colors.pinkAccent,
    ),
  ];
}
