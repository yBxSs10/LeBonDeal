import 'package:flutter/material.dart';

class DealTemperatureWidget extends StatelessWidget {
  const DealTemperatureWidget({super.key, required this.temperature});

  final int temperature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: temperature > 50 ? Colors.red[50] : Colors.blue[50],
      child: Row(
        children: [
          Icon(
            temperature > 50 ? Icons.local_fire_department : Icons.ac_unit,
            color: temperature > 50 ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            'Température: $temperature°',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: temperature > 50 ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
