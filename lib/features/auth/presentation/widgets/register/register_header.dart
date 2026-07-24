import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/shared/lebondeal_logo.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const LebonDealLogo(height: 72),
        const SizedBox(height: 16),
        Text(
          'Rejoins LebonDeal',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Crée ton compte pour accéder aux meilleurs deals et partager les tiens.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
