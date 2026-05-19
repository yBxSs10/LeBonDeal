import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSubmitting;
  final VoidCallback? onPublish;

  const FormHeader({Key? key, required this.isSubmitting, this.onPublish})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Ajouter un deal'),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : onPublish,
          child: isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publier'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
