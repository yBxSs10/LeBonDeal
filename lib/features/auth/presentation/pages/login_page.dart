import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/auth_provider.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../widgets/login/login_bottom_cta.dart';
import '../widgets/login/login_divider.dart';
import '../widgets/login/login_header.dart';
import '../widgets/login/login_social_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    
    try {
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } catch (e) {
      // L'erreur est déjà gérée dans le AuthProvider
    }
  }


  Widget _buildLoginButton(AuthProvider authProvider) {
    return ElevatedButton(
      onPressed: authProvider.isLoading
          ? null
          : () => _handleSubmit(authProvider),
      child: authProvider.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Se connecter'),
    );
  }

  Widget _buildGuestLoginButton(AuthProvider authProvider) {
    return OutlinedButton(
      onPressed: authProvider.isLoading
          ? null
          : () => _handleGuestLogin(authProvider),
      child: const Text('Continuer en tant qu\'invité'),
    );
  }

  Future<void> _handleGuestLogin(AuthProvider authProvider) async {
    try {
      await authProvider.signInAnonymously();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } catch (e) {
      // L'erreur est déjà gérée dans le AuthProvider
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32.0),
                const LoginHeader(),
                const SizedBox(height: 32.0),
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                _buildLoginButton(authProvider),
                const SizedBox(height: 16.0),
                _buildGuestLoginButton(authProvider),
                const SizedBox(height: 16.0),
                const LoginDivider(),
                const SizedBox(height: 24.0),
                const LoginSocialButtons(),
                const SizedBox(height: 24.0),
                const LoginBottomCta(),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
