import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';

class CodCollectionCard extends StatelessWidget {
  final double expectedAmount;
  final TextEditingController controller;

  const CodCollectionCard({
    super.key,
    required this.expectedAmount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COD Collection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Expected: \$${expectedAmount.toStringAsFixed(2)}'),
            Text('Tolerance: +\$${AppConfig.codTolerance.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Collected Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


