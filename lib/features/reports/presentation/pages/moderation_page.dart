import 'package:flutter/material.dart';

import 'package:lebondeal/core/di/injection.dart';
import 'package:lebondeal/core/widgets/shared/common_widgets.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/reports/domain/domain.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  bool _showResolved = false;

  Future<void> _dismiss(ReportEntity report) async {
    await ResolveReportUseCase(getIt<ReportRepository>())(report.id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signalement ignoré.')));
    }
  }

  Future<void> _deleteTarget(ReportEntity report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce deal ?'),
        content: Text(
          '"${report.targetTitle}" sera définitivement supprimé. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (report.targetType == 'deal') {
      await getIt<FirestoreService>().deleteDeal(report.targetId);
    }
    await ResolveReportUseCase(getIt<ReportRepository>())(report.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deal supprimé, signalement traité.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modération')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showResolved ? 'Signalements traités' : 'En attente',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _showResolved = !_showResolved),
                  child: Text(
                    _showResolved ? 'Voir en attente' : 'Voir traités',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ReportEntity>>(
              stream: GetReportsUseCase(getIt<ReportRepository>())(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                final reports = (snapshot.data ?? [])
                    .where((r) => _showResolved ? !r.isPending : r.isPending)
                    .toList();

                if (reports.isEmpty) {
                  return EmptyStateWidget(
                    message: _showResolved
                        ? 'Aucun signalement traité'
                        : 'Aucun signalement en attente',
                    icon: Icons.flag_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.targetTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Motif : ${report.reason}'),
                            const SizedBox(height: 8),
                            if (!report.isPending)
                              const Chip(label: Text('Traité'))
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _dismiss(report),
                                    child: const Text('Ignorer'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => _deleteTarget(report),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
