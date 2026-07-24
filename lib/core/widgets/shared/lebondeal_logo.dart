import 'package:flutter/material.dart';

class LebonDealLogo extends StatelessWidget {
  const LebonDealLogo({super.key, this.height = 48, this.semanticLabel});

  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'assets/brand/lebondeal.png',
        height: height,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel ?? 'Logo LebonDeal',
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: height * 2,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                'LebonDeal',
                style: TextStyle(
                  fontSize: height * 0.3,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
