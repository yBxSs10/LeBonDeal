import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthGuardWidget extends StatelessWidget {
  const AuthGuardWidget({
    super.key,
    required this.child,
    this.fallbackTitle = 'Accès refusé',
    this.fallbackMessage = 'Vous n\'avez pas les autorisations nécessaires pour ajouter une offre.',
    this.fallbackButtonText = 'Retour',
  });

  final Widget child;
  final String fallbackTitle;
  final String fallbackMessage;
  final String fallbackButtonText;

  @override
  Widget build(BuildContext context) {
    final user = auth.FirebaseAuth.instance.currentUser;
    
    if (user == null || user.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: Text(fallbackTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fallbackMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(fallbackButtonText),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
