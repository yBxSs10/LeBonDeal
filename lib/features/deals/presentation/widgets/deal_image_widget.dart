import 'package:flutter/material.dart';

class DealImageWidget extends StatelessWidget {
  const DealImageWidget({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[200], child: const Icon(Icons.image));
        },
      ),
    );
  }
}
