import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/auth_provider.dart';
import '../widgets/register/register_bottom_cta.dart';
import '../widgets/register/register_divider.dart';
import '../widgets/register/register_form.dart';
import '../widgets/register/register_header.dart';
import '../widgets/register/register_social_buttons.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Les mots de passe ne correspondent pas');
      return;
    }

    try {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (!mounted) return;
      // RegisterPage a été empilée par-dessus _AuthGate (app.dart), qui
      // a déjà basculé vers MainNavigation dès la connexion réussie
      // (authStateChanges) — il suffit de revenir à la racine plutôt que
      // de pousser HomePage() manuellement (ce qui affichait un écran
      // sans barre de navigation).
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    } catch (_) {
      // authProvider.signUp() relance après avoir déjà stocké le message
      // localisé (AuthRepositoryImpl._mapAuthExceptionToMessage) dans
      // authProvider.error — pas besoin de le re-mapper ici.
      _showMessage(authProvider.error ?? 'Une erreur inattendue est survenue');
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    // signInWithGoogle() ne relance jamais d'exception (erreur exposée via
    // authProvider.error), donc pas de try/catch nécessaire ici.
    await authProvider.signInWithGoogle();
    if (!mounted) return;
    if (authProvider.error != null) {
      _showMessage(authProvider.error!);
      return;
    }
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 32),
                  RegisterForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isSubmitting: authProvider.isLoading,
                    obscurePassword: _obscurePassword,
                    onSubmit: () => _submitForm(authProvider),
                    onAlreadyHaveAccount: () => Navigator.of(context).pop(),
                    onTogglePasswordVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 24),
                  const RegisterDivider(),
                  const SizedBox(height: 16),
                  RegisterSocialButtons(
                    onGooglePressed: () => _handleGoogleSignIn(authProvider),
                    onFacebookPressed: () =>
                        _showMessage('Connexion avec Facebook à implémenter'),
                  ),
                  const SizedBox(height: 32),
                  RegisterBottomCta(
                    onTermsPressed: () =>
                        _showMessage('Conditions d\'utilisation à implémenter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
}
