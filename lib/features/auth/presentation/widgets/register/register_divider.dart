import 'package:flutter/material.dart';

class RegisterDivider extends StatelessWidget {
  const RegisterDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou continuer avec',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
