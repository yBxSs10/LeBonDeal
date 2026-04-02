import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentFormWidget extends StatefulWidget {
  const CommentFormWidget({
    super.key,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final Future<void> Function(String content) onSubmit;
  final bool isSubmitting;

  @override
  State<CommentFormWidget> createState() => _CommentFormWidgetState();
}

class _CommentFormWidgetState extends State<CommentFormWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canPostComment) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Connectez-vous pour laisser un commentaire.',
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    return Column(
      children: [
        TextField(
          controller: _controller,
          minLines: 1,
          maxLines: 4,
          enabled: !widget.isSubmitting,
          decoration: const InputDecoration(
            hintText: 'Partagez votre avis…',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: widget.isSubmitting ? null : () => _handleSubmit(),
            icon: widget.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(widget.isSubmitting ? 'Envoi…' : 'Publier'),
          ),
        ),
      ],
    );
  }

  bool get _canPostComment {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }

  void _handleSubmit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    widget.onSubmit(content).then((_) {
      if (mounted) {
        _controller.clear();
      }
    });
  }
}
