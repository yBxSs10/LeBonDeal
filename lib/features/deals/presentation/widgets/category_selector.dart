import 'package:flutter/material.dart';
import 'package:lebondeal/features/categories/domain/domain.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;
  final List<Category> categories;
  final String? Function(String?)? validator;

  const CategorySelector({
    Key? key,
    required this.selectedCategoryId,
    required this.onChanged,
    required this.categories,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: const InputDecoration(labelText: 'Catégorie *'),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Row(
            children: [
              Icon(category.icon, size: 20, color: category.color),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;
      },
    );
  }
}
