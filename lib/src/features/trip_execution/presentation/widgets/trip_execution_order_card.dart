import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';

class TripExecutionOrderCard extends StatelessWidget {
  final Order order;

  const TripExecutionOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order: ${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (order.codAmount > 0)
                  Text(
                    'COD: \$${order.codAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (order.isDiscounted) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No Partial Delivery Allowed',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            ...order.items.map<Widget>(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${item.name} (Qty: ${item.quantity})'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Weight: ${order.totalWeight.toStringAsFixed(1)} kg',
                ),
                const SizedBox(width: 16),
                Text(
                  'Total Volume: ${order.totalVolume.toStringAsFixed(3)} m³',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


