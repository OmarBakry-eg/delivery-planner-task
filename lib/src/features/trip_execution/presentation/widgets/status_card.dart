
import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/delivery.dart';

class StatusCard extends StatelessWidget {
  final DeliveryStatus status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String statusText = '';

    switch (status) {
      case DeliveryStatus.pending:
        color = Colors.grey;
        statusText = 'Pending';
        break;
      case DeliveryStatus.inTransit:
        color = Colors.orange;
        statusText = 'In Transit';
        break;
      case DeliveryStatus.completed:
        color = Colors.green;
        statusText = 'Completed';
        break;
      case DeliveryStatus.failed:
        color = Colors.red;
        statusText = 'Failed';
        break;
    }

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getStatusIcon(status), color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.schedule;
      case DeliveryStatus.inTransit:
        return Icons.local_shipping;
      case DeliveryStatus.completed:
        return Icons.check_circle;
      case DeliveryStatus.failed:
        return Icons.error;
    }
  }
}

