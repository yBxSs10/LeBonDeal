import 'package:flutter/material.dart';

class PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final bool isRequired;

  const PriceField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint = '€',
    this.validator,
    this.isRequired = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: '€ ',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Obligatoire';
          }
          if (value != null && value.isNotEmpty) {
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Prix invalide';
            }
          }
          return validator?.call(value);
        },
      ),
    );
  }
}
