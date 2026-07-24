import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/features/reports/domain/domain.dart';

const _reportReasons = [
  'Deal frauduleux',
  'Deal expiré',
  'Contenu inapproprié',
  'Autre',
];

Future<void> showReportDealDialog(
  BuildContext context, {
  required String dealId,
  required String dealTitle,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connectez-vous pour signaler un deal.')),
    );
    return;
  }

  final reason = await showDialog<String>(
    context: context,
    builder: (context) => _ReportReasonDialog(),
  );
  if (reason == null || !context.mounted) return;

  await CreateReportUseCase(getIt<ReportRepository>())(
    targetId: dealId,
    targetType: 'deal',
    targetTitle: dealTitle,
    reason: reason,
    authorId: user.uid,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signalement envoyé. Merci.')));
  }
}

class _ReportReasonDialog extends StatefulWidget {
  @override
  State<_ReportReasonDialog> createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<_ReportReasonDialog> {
  String _selected = _reportReasons.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Signaler ce deal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final reason in _reportReasons)
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: Text(reason),
              value: reason,
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value!),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Signaler'),
        ),
      ],
    );
  }
}
