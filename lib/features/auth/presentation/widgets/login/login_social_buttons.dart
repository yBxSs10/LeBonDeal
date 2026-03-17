import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/theme/app_colors.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SocialButton(label: 'Google', iconData: FontAwesomeIcons.google),
        SizedBox(height: 12),
        _SocialButton(label: 'Facebook', iconData: FontAwesomeIcons.facebookF),
        SizedBox(height: 12),
        _SocialButton(label: 'Apple', iconData: FontAwesomeIcons.apple),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.iconData});

  final String label;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Connexion $label à implémenter'))),
        icon: FaIcon(iconData, color: AppColors.textPrimary),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
