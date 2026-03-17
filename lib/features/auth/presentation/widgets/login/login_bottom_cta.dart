import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../pages/register_page.dart';

class LoginBottomCta extends StatelessWidget {
  const LoginBottomCta({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text('Créer un compte'),
        ),
      ],
    );
  }
}
