import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_hsa_group/src/core/utils/timezone_utils.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/trip.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/screens/trip_execution_screen.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final bool expanded;

  const TripCard({super.key, required this.trip, this.expanded = false});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  Trip? _liveTrip;
  StreamSubscription? _repoSub;

  @override
  void initState() {
    super.initState();
    final repo = context.read<TripRepository>();
    _repoSub = repo.changes.listen((data) {
      final updated = data.trips.firstWhereOrNull(
        (t) => t.id == widget.trip.id,
      );
      if (updated == null) return;
      final prevSig = _signature(_liveTrip ?? widget.trip);
      final nextSig = _signature(updated);
      if (prevSig != nextSig) {
        setState(() {
          _liveTrip = updated;
        });
      }
    });
  }

  @override
  void dispose() {
    _repoSub?.cancel();
    super.dispose();
  }

  String _signature(Trip t) => t.stops
      .map(
        (s) =>
            '${s.orderId}:${s.status.index}:${s.completedAt?.millisecondsSinceEpoch ?? 0}',
      )
      .join('|');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripPlanningCubit, TripPlanningState>(
      buildWhen: (prev, curr) {
        if (prev is TripPlanningLoaded && curr is TripPlanningLoaded) {
          final prevTrip = prev.trips.firstWhereOrNull(
            (t) => t.id == widget.trip.id,
          );
          final currTrip = curr.trips.firstWhereOrNull(
            (t) => t.id == widget.trip.id,
          );
          if (prevTrip == null || currTrip == null) return true;
          String sig(Trip t) => t.stops
              .map(
                (s) =>
                    '${s.orderId}:${s.status.index}:${s.completedAt?.millisecondsSinceEpoch ?? 0}',
              )
              .join('|');
          return sig(prevTrip) != sig(currTrip);
        }
        return true;
      },
      builder: (context, state) {
        if (state is! TripPlanningLoaded) {
          return const SizedBox.shrink();
        }
        final currentTrip =
            _liveTrip ??
            state.trips.firstWhereOrNull((t) => t.id == widget.trip.id) ??
            widget.trip;
        final vehicle = state.vehicles.firstWhere(
          (v) => v.id == currentTrip.vehicleId,
        );
        final repo = context.read<TripRepository>();
        final orders = currentTrip.stops.map<Order?>((s) {
          try {
            return repo.getOrderById(s.orderId);
          } catch (_) {
            return null;
          }
        }).toList();
        final totalCod = currentTrip.getTotalCod(orders);
        final completedStops = currentTrip.stops
            .where((s) => s.status == DeliveryStatus.completed)
            .length;
        final inTransitStops = currentTrip.stops
            .where((s) => s.status == DeliveryStatus.inTransit)
            .length;
        final totalStops = currentTrip.stops.length;
        final remainingStops = totalStops - completedStops;

        final isCompleted = currentTrip.isCompleted;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: widget.expanded
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
                : const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrip.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('${vehicle.name} • $totalStops stops'),
                          Text(
                            TimezoneUtils.formatInTimezone(
                              currentTrip.createdAt,
                              state.depotTimezone,
                            ),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'execute') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripExecutionScreen(tripId: currentTrip.id),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Trip'),
                                content: const Text(
                                  'Are you sure you want to delete this trip?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              if (context.mounted) {
                                final result = await context
                                    .read<TripPlanningCubit>()
                                    .deleteTrip(currentTrip.id);
                                if (result != 'Success') {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result)),
                                    );
                                  }
                                }
                              }
                            }
                          } else if (value == 'map') {
                            _showTripMap(context, currentTrip);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'execute',
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow),
                                SizedBox(width: 8),
                                Text('Execute Trip'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'map',
                            child: Row(
                              children: [
                                Icon(Icons.map),
                                SizedBox(width: 8),
                                Text('View Map'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (isCompleted)
                      const Icon(Icons.done_all, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total COD: \$${totalCod.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (remainingStops > 0)
                          Text(
                            'Progress: $inTransitStops/$remainingStops',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        Text(
                          'Completed: $completedStops/$totalStops',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.expanded) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Stops (${currentTrip.stops.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentTrip.stops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stop = entry.value;
                    final repo = context.read<TripRepository>();
                    final order = orders.firstWhereOrNull(
                      (o) => o?.id == stop.orderId,
                    );
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                Text(
                                  'COD: \$${safeOrder.codAmount.toStringAsFixed(2)}',
                                ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTripMap(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              AppBar(
                title: Text('Trip Map - ${trip.id}'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(
                      25.2048,
                      55.2708,
                    ), // Dubai depot
                    initialZoom: 11.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.deliverydispatcher.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Depot marker
                        Marker(
                          point: const LatLng(25.2048, 55.2708),
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.home,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        // Stop markers
                        ...trip.stops.asMap().entries.map((entry) {
                          final index = entry.key;
                          final stop = entry.value;
                          Color color = Colors.red;
                          switch (stop.status) {
                            case DeliveryStatus.completed:
                              color = Colors.green;
                              break;
                            case DeliveryStatus.inTransit:
                              color = Colors.orange;
                              break;
                            case DeliveryStatus.failed:
                              color = Colors.red;
                              break;
                            case DeliveryStatus.pending:
                              color = Colors.grey;
                              break;
                          }

                          return Marker(
                            point: LatLng(
                              stop.location.latitude,
                              stop.location.longitude,
                            ),
                            width: 28,
                            height: 28,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
