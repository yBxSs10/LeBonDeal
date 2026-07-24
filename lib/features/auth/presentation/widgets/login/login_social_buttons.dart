import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key, this.onGooglePressed});

  final VoidCallback? onGooglePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: 'Google',
          brandLetter: 'G',
          onPressed:
              onGooglePressed ??
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connexion Google à implémenter')),
              ),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Facebook',
          brandLetter: 'f',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion Facebook à implémenter')),
          ),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Apple',
          brandLetter: '',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion Apple à implémenter')),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.brandLetter,
    required this.onPressed,
  });

  final String label;
  final String brandLetter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Text(
          brandLetter,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
