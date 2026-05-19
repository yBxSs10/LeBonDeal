import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../lebondeal_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const LebonDealLogo(height: 72),
        const SizedBox(height: 16),
        Text(
          'Bienvenue sur LebonDeal',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Connecte-toi pour découvrir les meilleurs deals de la communauté.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
