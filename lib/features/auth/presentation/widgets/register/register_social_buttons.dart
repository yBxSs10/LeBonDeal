import 'package:flutter/material.dart';

class RegisterSocialButtons extends StatelessWidget {
  const RegisterSocialButtons({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          brandLetter: 'G',
          label: 'Continuer avec Google',
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: 12),
        _SocialButton(
          brandLetter: 'f',
          label: 'Continuer avec Facebook',
          onPressed: onFacebookPressed,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.brandLetter,
    required this.label,
    required this.onPressed,
  });

  final String brandLetter;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Text(
        brandLetter,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
