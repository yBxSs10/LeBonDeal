import 'package:flutter/material.dart';

class LebonDealLogo extends StatelessWidget {
  final double height;
  
  const LebonDealLogo({
    super.key,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        'assets/images/lebondeal.png', // Chemin vers le logo LeBonDeal
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback si l'image n'est pas trouvée
          return const FlutterLogo(size: 60);
        },
      ),
    );
  }
}
