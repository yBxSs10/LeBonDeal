import 'package:flutter/material.dart';

import '../../../../core/widgets/shared/common_widgets.dart';
import '../../data/datasources/remote/firestore_service.dart';
import '../../domain/entities/deal.dart';
import '../widgets/deal_card.dart';

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tendances')),
      body: StreamBuilder<List<Deal>>(
        stream: FirestoreService.getTrendingDealsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return CustomErrorWidget(message: 'Erreur : ${snapshot.error}');
          }
          final deals = snapshot.data ?? [];
          if (deals.isEmpty) {
            return const EmptyStateWidget(
              message: 'Aucun deal tendance pour le moment',
              icon: Icons.trending_up,
            );
          }
          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) => DealCard(deal: deals[index]),
          );
        },
      ),
    );
  }
}
