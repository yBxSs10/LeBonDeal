import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final bool obscureText;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.validator,
    this.isRequired = true,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Ce champ est obligatoire';
        }
        return validator?.call(value);
      },
    );
  }
}
