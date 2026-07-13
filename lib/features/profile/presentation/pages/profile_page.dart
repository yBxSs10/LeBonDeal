import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:lebondeal/core/widgets/shared/common_widgets.dart';
import 'package:lebondeal/core/widgets/shared/lebondeal_logo.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: EmptyStateWidget(
          message: 'Aucun utilisateur connecté',
          icon: Icons.person_off,
          action: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Se connecter'),
          ),
        ),
      );
    }

    final displayName =
        user.displayName ?? user.email?.split('@')[0] ?? 'Utilisateur';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Semantics(
                    label: 'Photo de profil de $displayName',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: user.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user.photoURL!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (user.emailVerified) ...[
                    const SizedBox(height: 8),
                    Semantics(
                      label: 'Compte vérifié',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'Compte vérifié',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Paramètres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Confidentialité'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showPrivacySettings(context),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide et support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showHelp(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'LeBonDeal',
                applicationVersion: '1.0.0',
                applicationIcon: const LebonDealLogo(height: 48),
                children: const [
                  Text('Application de partage de bons plans et deals.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialité'),
        content: const Text(
          '• Profil public\n• Données personnelles\n• Cookies',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide et support'),
        content: const Text('• FAQ\n• Contact support\n• Signaler un problème'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await auth.FirebaseAuth.instance.signOut();
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
