import 'package:flutter/material.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';

class DealDescriptionWidget extends StatelessWidget {
  const DealDescriptionWidget({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(deal.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text(
            'Posté par ' + deal.author,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
