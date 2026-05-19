import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/domain.dart';
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
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  final AuthRepository _authRepository = getIt<AuthRepository>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Les mots de passe ne correspondent pas');
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await _authRepository.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      result.fold(
        (error) {
          String errorMessage = 'Une erreur est survenue';

          if (error.contains('email-already-in-use')) {
            errorMessage = 'Un compte existe déjà avec cet email';
          } else if (error.contains('weak-password')) {
            errorMessage =
                'Le mot de passe est trop faible (6 caractères minimum)';
          } else if (error.contains('invalid-email')) {
            errorMessage = 'Adresse email invalide';
          } else if (error.contains('operation-not-allowed')) {
            errorMessage = 'Les inscriptions sont temporairement désactivées';
          } else if (error.contains('too-many-requests')) {
            errorMessage = 'Trop de tentatives. Réessayez plus tard.';
          }

          _showMessage(errorMessage);
        },
        (user) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      );
    } catch (e) {
      _showMessage('Une erreur inattendue est survenue');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
                    isSubmitting: _isSubmitting,
                    obscurePassword: _obscurePassword,
                    onSubmit: _submitForm,
                    onAlreadyHaveAccount: () => Navigator.of(context).pop(),
                    onTogglePasswordVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 24),
                  const RegisterDivider(),
                  const SizedBox(height: 16),
                  RegisterSocialButtons(
                    onGooglePressed: () =>
                        _showMessage('Connexion avec Google à implémenter'),
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
