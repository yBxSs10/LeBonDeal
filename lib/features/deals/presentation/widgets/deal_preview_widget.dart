import 'package:flutter/material.dart';

class DealPreviewWidget extends StatelessWidget {
  const DealPreviewWidget({
    super.key,
    required this.title,
    required this.description,
    required this.storeName,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String storeName;
  final double price;
  final double? originalPrice;
  final String imageUrl;

  bool get _hasRequiredFields =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      storeName.isNotEmpty &&
      price > 0;

  int get _discountPercent {
    if (originalPrice != null && originalPrice! > 0) {
      return ((originalPrice! - price) / originalPrice! * 100).round();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRequiredFields) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Remplissez les champs obligatoires pour voir la prévisualisation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildImageSection(), _buildDealInfo()],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, size: 50, color: Colors.grey[400]);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Icon(Icons.image, size: 50, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildDealInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            storeName,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '€${price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (originalPrice != null)
          Text(
            '€${originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (_discountPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '-$_discountPercent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
