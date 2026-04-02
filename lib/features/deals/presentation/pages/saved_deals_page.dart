import 'package:flutter/material.dart';
import '../../data/datasources/remote/data_service.dart';
import '../widgets/deal_card.dart';
import '../../../../core/widgets/shared/common_widgets.dart';

class SavedDealsPage extends StatefulWidget {
  const SavedDealsPage({super.key});

  @override
  State<SavedDealsPage> createState() => _SavedDealsPageState();
}

class _SavedDealsPageState extends State<SavedDealsPage> {
  final List<String> _savedDealIds = ['1', '3', '5']; // Mock data

  @override
  Widget build(BuildContext context) {
    final savedDeals = DataService.getSavedDeals(_savedDealIds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deals sauvegardés'),
      ),
      body: savedDeals.isEmpty
          ? const EmptyStateWidget(
              message: 'Vous n\'avez pas encore sauvegardé de deals',
              icon: Icons.favorite_border,
            )
          : ListView.builder(
              itemCount: savedDeals.length,
              itemBuilder: (context, index) {
                final deal = savedDeals[index];
                return DealCard(
                  deal: deal,
                  isSaved: true,
                  onSave: () {
                    setState(() {
                      _savedDealIds.remove(deal.id);
                    });
                  },
                );
              },
            ),
    );
  }
}
