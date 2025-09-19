import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/orders/data/models/order.dart';
import 'package:test_hsa_group/src/features/trip_execution/domain/entities/delivery.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_state.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';

class TripExecutionCubit extends Cubit<TripExecutionState> {
  final TripRepository _repository;

  TripExecutionCubit(this._repository) : super(TripExecutionInitial());

  Future<void> loadTrip(String tripId) async {
    try {
      int? preservedIndex;
      final existing = state;
      if (existing is TripExecutionLoaded && existing.trip.id == tripId) {
        preservedIndex = existing.currentStopIndex;
      }
      emit(TripExecutionLoading());

      final appData = await _repository.loadData();
      final trip = appData.trips.firstWhere((t) => t.id == tripId);

      final orders = trip.stops
          .map((stop) => appData.orders.firstWhere((o) => o.id == stop.orderId))
          .toList();

      emit(
        TripExecutionLoaded(
          trip: trip,
          orders: orders,
          customers: appData.customers,
          currentStopIndex: preservedIndex ?? 0,
        ),
      );
    } catch (e) {
      emit(TripExecutionError('Failed to load trip: $e'));
    }
  }

  void navigateToStop(int index) {
    final currentState = state;
    if (currentState is TripExecutionLoaded) {
      if (index >= 0 && index < currentState.trip.stops.length) {
        emit(currentState.copyWith(currentStopIndex: index));
      }
    }
  }

  void nextStop() {
    final currentState = state;
    if (currentState is TripExecutionLoaded && currentState.hasNextStop) {
      emit(
        currentState.copyWith(
          currentStopIndex: currentState.currentStopIndex + 1,
        ),
      );
    }
  }

  void previousStop() {
    final currentState = state;
    if (currentState is TripExecutionLoaded && currentState.hasPreviousStop) {
      emit(
        currentState.copyWith(
          currentStopIndex: currentState.currentStopIndex - 1,
        ),
      );
    }
  }

  Future<String> updateStopStatus(
    DeliveryStatus newStatus, {
    double? collectedCod,
    List<String>? failureReasons,
    List<String>? serialNumbers,
  }) async {
    try {
      final currentState = state;
      if (currentState is! TripExecutionLoaded) return 'Invalid state';

      final currentStop = currentState.currentStop;
      final order = currentState.getCurrentOrder();

      // Validate state transition
      if (!currentStop.status.canTransitionTo(newStatus)) {
        return 'Cannot transition from ${_getStatusDisplayName(currentStop.status)} to ${_getStatusDisplayName(newStatus)}';
      }

      // Business rule validations
      if (newStatus == DeliveryStatus.completed) {
        // COD validation
        if (order.codAmount > 0) {
          if (collectedCod == null) {
            return 'COD amount must be collected for this order';
          }
          if (collectedCod < order.codAmount) {
            return 'COD shortfall not allowed. Expected: \$${order.codAmount.toStringAsFixed(2)}, Collected: \$${collectedCod.toStringAsFixed(2)}';
          }
          if (collectedCod > order.codAmount + AppConfig.codTolerance) {
            return 'COD over-collection exceeds tolerance. Expected: \$${order.codAmount.toStringAsFixed(2)}, Collected: \$${collectedCod.toStringAsFixed(2)}, Max allowed: \$${(order.codAmount + AppConfig.codTolerance).toStringAsFixed(2)}';
          }
        }

        // Serial number validation
        for (final item in order.items) {
          if (item.serialTracked && item.quantity > 1) {
            final providedSerials =
                serialNumbers?.where((s) => s.isNotEmpty).length ?? 0;
            if (providedSerials != item.quantity) {
              return 'Item "${item.name}" requires ${item.quantity} unique serial numbers';
            }

            final uniqueSerials = (serialNumbers ?? [])
                .where((s) => s.isNotEmpty)
                .toSet();
            if (uniqueSerials.length != item.quantity) {
              return 'Item "${item.name}" requires unique serial numbers';
            }
          }
        }

        // Partial delivery validation
        if (order.isDiscounted) {
          // For discounted orders, we don't allow partial deliveries
          // This is implicitly handled by requiring all validations to pass
        }
      }

      // Update the order with serial numbers if provided
      if (serialNumbers != null && serialNumbers.isNotEmpty) {
        Order updatedOrder = order;
        List<String> remainingSerials = [...serialNumbers];
        for (int i = 0; i < order.items.length; i++) {
          final item = order.items[i];
          if (item.serialTracked && item.quantity > 1) {
            final itemSerials = remainingSerials.take(item.quantity).toList();
            remainingSerials = remainingSerials.skip(item.quantity).toList();

            final updatedItem = item.copyWith(serialNumbers: itemSerials);
            final updatedItems = [...order.items];
            updatedItems[i] = updatedItem;
            updatedOrder = order.copyWith(items: updatedItems);
          }
        }
        await _repository.updateOrder(updatedOrder);
      }

      // Update the stop
      final updatedStop = currentStop.copyWith(
        status: newStatus,
        collectedCod: newStatus == DeliveryStatus.completed
            ? collectedCod
            : null,
        failureReasons: failureReasons ?? [],
        completedAt:
            newStatus == DeliveryStatus.completed ||
                newStatus == DeliveryStatus.failed
            ? DateTime.now()
            : null,
      );

      final updatedStops = [...currentState.trip.stops];
      updatedStops[currentState.currentStopIndex] = updatedStop;

      final updatedTrip = currentState.trip.copyWith(stops: updatedStops);
      await _repository.saveTrip(updatedTrip);

      // Refresh the state
      await loadTrip(currentState.trip.id);
      return 'Success';
    } catch (e) {
      return 'Failed to update stop status: $e';
    }
  }

  String _getStatusDisplayName(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }

  List<DeliveryStatus> getValidTransitions(DeliveryStatus currentStatus) {
    switch (currentStatus) {
      case DeliveryStatus.pending:
        return [DeliveryStatus.inTransit, DeliveryStatus.failed];
      case DeliveryStatus.inTransit:
        return [DeliveryStatus.completed, DeliveryStatus.failed];
      case DeliveryStatus.completed:
      case DeliveryStatus.failed:
        return [];
    }
  }
}
