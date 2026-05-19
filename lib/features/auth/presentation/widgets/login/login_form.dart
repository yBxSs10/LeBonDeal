import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required bool isSubmitting,
    required VoidCallback onSubmit,
    required VoidCallback onGuestLogin,
    required VoidCallback onForgotPassword,
  }) : _formKey = formKey,
       _emailController = emailController,
       _passwordController = passwordController,
       _isSubmitting = isSubmitting,
       _onSubmit = onSubmit,
       _onGuestLogin = onGuestLogin,
       _onForgotPassword = onForgotPassword;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final bool _isSubmitting;
  final VoidCallback _onSubmit;
  final VoidCallback _onGuestLogin;
  final VoidCallback _onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
              hintText: 'votre@email.com',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Merci de saisir ton email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _PasswordField(controller: _passwordController),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _onForgotPassword,
            child: const Text('Mot de passe oublié ?'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _onSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Se connecter'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isSubmitting ? null : _onGuestLogin,
            child: const Text('Continuer en tant qu\'invité'),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: Semantics(
          label: _obscure
              ? 'Afficher le mot de passe'
              : 'Masquer le mot de passe',
          button: true,
          child: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Merci de saisir ton mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }
}
