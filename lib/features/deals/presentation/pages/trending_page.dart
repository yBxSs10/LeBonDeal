import 'package:flutter/material.dart';
import '../../data/datasources/remote/data_service.dart';
import '../widgets/deal_card.dart';
import '../../../../core/widgets/shared/common_widgets.dart';

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trendingDeals = DataService.getTrendingDeals();

    return Scaffold(
      appBar: AppBar(title: const Text('Tendances')),
      body: trendingDeals.isEmpty
          ? const EmptyStateWidget(
              message: 'Aucun deal tendance pour le moment',
              icon: Icons.trending_up,
            )
          : ListView.builder(
              itemCount: trendingDeals.length,
              itemBuilder: (context, index) {
                final deal = trendingDeals[index];
                return DealCard(deal: deal);
              },
            ),
    );
  }
}
