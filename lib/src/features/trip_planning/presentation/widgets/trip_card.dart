import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/utils/timezone_utils.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/data/models/trip.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_state.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/trip_card_expanded_widget.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/widgets/trip_card_popup_button.dart';

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
    final repo = context.read<TripPlanningRepository>();
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
        final repo = context.read<TripPlanningRepository>();
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
                      TripCardPopupMenuButton(currentTrip: currentTrip),
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
                  TripCardExpandedWidget(
                    currentTrip: currentTrip,
                    orders: orders,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
