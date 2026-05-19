import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required bool isSubmitting,
    required bool obscurePassword,
    required VoidCallback onSubmit,
    required VoidCallback onAlreadyHaveAccount,
    required VoidCallback onTogglePasswordVisibility,
  }) : _formKey = formKey,
       _nameController = nameController,
       _emailController = emailController,
       _passwordController = passwordController,
       _confirmPasswordController = confirmPasswordController,
       _isSubmitting = isSubmitting,
       _obscurePassword = obscurePassword,
       _onSubmit = onSubmit,
       _onAlreadyHaveAccount = onAlreadyHaveAccount,
       _onTogglePasswordVisibility = onTogglePasswordVisibility;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;
  final bool _isSubmitting;
  final bool _obscurePassword;
  final VoidCallback _onSubmit;
  final VoidCallback _onAlreadyHaveAccount;
  final VoidCallback _onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.person_outline_rounded),
              hintText: 'Jean Dupont',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'exemple@email.com',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _passwordController,
            label: 'Mot de passe',
            obscureText: _obscurePassword,
            onToggleVisibility: _onTogglePasswordVisibility,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmer le mot de passe',
            obscureText: _obscurePassword,
            onToggleVisibility: _onTogglePasswordVisibility,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _onSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Créer mon compte'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isSubmitting ? null : _onAlreadyHaveAccount,
            child: const Text('Déjà un compte ? Connectez-vous'),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
