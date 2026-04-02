import 'package:flutter/material.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';

class DealInfoWidget extends StatelessWidget {
  const DealInfoWidget({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            deal.storeName,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                deal.priceLabel,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              if (deal.discountPercent > 0) ...[
                const SizedBox(width: 12),
                Text(
                  deal.originalPriceLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '-${deal.discountPercent}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
