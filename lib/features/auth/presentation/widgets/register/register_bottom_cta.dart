import 'package:flutter/material.dart';

class RegisterBottomCta extends StatelessWidget {
  const RegisterBottomCta({
    super.key,
    required this.onTermsPressed,
  });

  final VoidCallback onTermsPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'En continuant, vous acceptez nos ',
          style: theme.textTheme.bodySmall,
        ),
        TextButton(
          onPressed: onTermsPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'conditions d\'utilisation',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
