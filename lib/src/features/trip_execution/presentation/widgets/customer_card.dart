import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/orders/data/models/customer.dart';



class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Name: ${customer.name}'),
            Text(
              'Location: ${customer.location.latitude.toStringAsFixed(4)}, ${customer.location.longitude.toStringAsFixed(4)}',
            ),
          ],
        ),
      ),
    );
  }
}

