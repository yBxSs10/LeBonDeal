import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SocialButton(label: 'Google', brandLetter: 'G'),
        SizedBox(height: 12),
        _SocialButton(label: 'Facebook', brandLetter: 'f'),
        SizedBox(height: 12),
        _SocialButton(label: 'Apple', brandLetter: ''),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.brandLetter});

  final String label;
  final String brandLetter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion $label à implémenter')),
        ),
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
