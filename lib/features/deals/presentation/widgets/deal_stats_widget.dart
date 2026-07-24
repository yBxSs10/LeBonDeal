import 'package:flutter/material.dart';

class DealStatsWidget extends StatelessWidget {
  const DealStatsWidget({
    super.key,
    required this.commentCount,
    required this.favorites,
    required this.shares,
  });

  final int commentCount;
  final int favorites;
  final int shares;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.comment, '$commentCount', 'Commentaires'),
          _buildStatItem(Icons.favorite, '$favorites', 'Favoris'),
          _buildStatItem(Icons.share, '$shares', 'Partages'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Semantics(
      label: '$count $label',
      excludeSemantics: true,
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
