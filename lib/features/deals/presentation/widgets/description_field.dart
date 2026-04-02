import 'package:flutter/material.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final String hint;
  final int maxLines;

  const DescriptionField({
    Key? key,
    required this.controller,
    this.validator,
    this.label = 'Description',
    this.hint = 'Décrivez votre article...',
    this.maxLines = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return validator?.call(value);
      },
    );
  }
}
