import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';

class TripCardExpandedWidget extends StatelessWidget {
  final Trip currentTrip;
  final List<Order?> orders;
  const TripCardExpandedWidget({
    super.key,
    required this.currentTrip,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Stops (${currentTrip.stops.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...currentTrip.stops.asMap().entries.map((entry) {
          final idx = entry.key;
          final stop = entry.value;
          final repo = context.read<TripPlanningRepository>();
          final order = orders.firstWhereOrNull((o) => o?.id == stop.orderId);
          final safeOrder = order ?? repo.getOrderById(stop.orderId);
          final customer = repo.getCustomerById(safeOrder.customerId);
          Color statusColor = Colors.grey;
          String statusText = 'Pending';
          switch (stop.status) {
            case DeliveryStatus.completed:
              statusColor = Colors.green;
              statusText = 'Completed';
              break;
            case DeliveryStatus.inTransit:
              statusColor = Colors.orange;
              statusText = 'In Transit';
              break;
            case DeliveryStatus.failed:
              statusColor = Colors.red;
              statusText = 'Failed';
              break;
            case DeliveryStatus.pending:
              statusColor = Colors.grey;
              statusText = 'Pending';
              break;
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Order: ${safeOrder.id} • $statusText',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Customer: ${customer.name}'),
                  Text(
                    'Location: ${customer.location.latitude.toStringAsFixed(4)}, ${customer.location.longitude.toStringAsFixed(4)}',
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    children: [
                      Text('COD: \$${safeOrder.codAmount.toStringAsFixed(2)}'),
                      const SizedBox(width: 12),
                      Text(
                        'Weight: ${safeOrder.totalWeight.toStringAsFixed(1)} kg',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Volume: ${safeOrder.totalVolume.toStringAsFixed(3)} m³',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
