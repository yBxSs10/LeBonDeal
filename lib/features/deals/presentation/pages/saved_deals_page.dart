import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/shared/common_widgets.dart';
import '../../data/datasources/remote/firestore_service.dart';
import '../../domain/entities/deal.dart';
import '../widgets/deal_card.dart';

class SavedDealsPage extends StatelessWidget {
  const SavedDealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deals sauvegardés')),
        body: const EmptyStateWidget(
          message: 'Connectez-vous pour voir vos deals sauvegardés',
          icon: Icons.favorite_border,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Deals sauvegardés')),
      body: StreamBuilder<List<Deal>>(
        stream: getIt<FirestoreService>().getSavedDealsStream(user.uid),
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
              message: "Vous n'avez pas encore sauvegardé de deals",
              icon: Icons.favorite_border,
            );
          }
          return ListView.builder(
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return DealCard(
                deal: deal,
                isSaved: true,
                onSave: () => getIt<FirestoreService>().toggleSavedDeal(
                  user.uid,
                  deal.id,
                  true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
